#import "BeaconManager.h"

@interface BeaconManager ()

@property (nonatomic, strong) CLBeaconRegion *beaconRegion;
@property (nonatomic, strong) NSString *targetUUID;
@property (nonatomic, strong) NSNumber *targetMajor;
@property (nonatomic, strong) NSNumber *targetMinor;

@end

@implementation BeaconManager

+ (instancetype)sharedManager {
    static BeaconManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[BeaconManager alloc] init];
    });
    return sharedManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.isDetecting = NO;
        [self requestNotificationPermission];
    }
    return self;
}

- (void)requestLocationPermission {
    [self.locationManager requestAlwaysAuthorization];
}

- (void)requestNotificationPermission {
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert + UNAuthorizationOptionSound + UNAuthorizationOptionBadge)
                          completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (!granted) {
            NSLog(@"Notification permission denied");
        }
    }];
}

- (void)startRangingBeaconsWithUUID:(NSString *)uuidString major:(NSNumber *)major minor:(NSNumber *)minor identifier:(NSString *)identifier {
    self.targetUUID = uuidString;
    self.targetMajor = major;
    self.targetMinor = minor;
    
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:uuidString];
    
    if (major && minor) {
        self.beaconRegion = [[CLBeaconRegion alloc] initWithUUID:uuid major:[major unsignedShortValue] minor:[minor unsignedShortValue] identifier:identifier];
    } else if (major) {
        self.beaconRegion = [[CLBeaconRegion alloc] initWithUUID:uuid major:[major unsignedShortValue] identifier:identifier];
    } else {
        self.beaconRegion = [[CLBeaconRegion alloc] initWithUUID:uuid identifier:identifier];
    }
    
    self.beaconRegion.notifyOnEntry = YES;
    self.beaconRegion.notifyOnExit = YES;
    self.beaconRegion.notifyEntryStateOnDisplay = YES;
    
    [self.locationManager startMonitoringForRegion:self.beaconRegion];
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
    
    self.isDetecting = YES;
    if ([self.delegate respondsToSelector:@selector(detectionStatusChanged:)]) {
        [self.delegate detectionStatusChanged:self.isDetecting];
    }
}

- (void)stopRangingBeacons {
    if (self.beaconRegion) {
        [self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];
        [self.locationManager stopMonitoringForRegion:self.beaconRegion];
        self.beaconRegion = nil;
    }
    
    self.isDetecting = NO;
    if ([self.delegate respondsToSelector:@selector(detectionStatusChanged:)]) {
        [self.delegate detectionStatusChanged:self.isDetecting];
    }
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            [self.locationManager requestWhenInUseAuthorization];
            break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        case kCLAuthorizationStatusAuthorizedAlways:
            NSLog(@"Location permission granted");
            break;
        case kCLAuthorizationStatusDenied:
        case kCLAuthorizationStatusRestricted:
            if ([self.delegate respondsToSelector:@selector(didFailWithError:)]) {
                NSError *error = [NSError errorWithDomain:@"BeaconManager" code:1001 userInfo:@{NSLocalizedDescriptionKey: @"Location permission denied"}];
                [self.delegate didFailWithError:error];
            }
            break;
    }
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray<CLBeacon *> *)beacons inRegion:(CLBeaconRegion *)region {
    // 指定したビーコンのみフィルタリング
    NSArray *filteredBeacons = [self filterTargetBeacons:beacons];
    
    // 検知したビーコンをデータベースに保存
    for (CLBeacon *beacon in filteredBeacons) {
        BeaconDetection *detection = [[BeaconDetection alloc] 
            initWithUUID:[beacon.proximityUUID UUIDString]
            major:beacon.major
            minor:beacon.minor
            detectedAt:[NSDate date]
            rssi:beacon.rssi
            accuracy:beacon.accuracy];
        
        [[BeaconDataManager sharedManager] saveBeaconDetection:detection];
    }
    
    if ([self.delegate respondsToSelector:@selector(didRangeBeacons:inRegion:)]) {
        [self.delegate didRangeBeacons:filteredBeacons inRegion:region];
    }
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    [self sendLocalNotification:@"ビーコンを検知しました" body:@"指定されたビーコンの範囲に入りました"];
    
    if ([self.delegate respondsToSelector:@selector(didEnterRegion:)]) {
        [self.delegate didEnterRegion:region];
    }
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    [self sendLocalNotification:@"ビーコンを検知終了" body:@"指定されたビーコンの範囲から出ました"];
    
    if ([self.delegate respondsToSelector:@selector(didExitRegion:)]) {
        [self.delegate didExitRegion:region];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(didFailWithError:)]) {
        [self.delegate didFailWithError:error];
    }
}

- (void)locationManager:(CLLocationManager *)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(didFailWithError:)]) {
        [self.delegate didFailWithError:error];
    }
}

#pragma mark - Private Methods

- (NSArray *)filterTargetBeacons:(NSArray<CLBeacon *> *)beacons {
    if (!self.targetUUID) {
        return beacons;
    }
    
    NSMutableArray *filteredBeacons = [[NSMutableArray alloc] init];
    for (CLBeacon *beacon in beacons) {
        BOOL uuidMatch = [[beacon.proximityUUID UUIDString] isEqualToString:self.targetUUID];
        BOOL majorMatch = !self.targetMajor || [beacon.major isEqualToNumber:self.targetMajor];
        BOOL minorMatch = !self.targetMinor || [beacon.minor isEqualToNumber:self.targetMinor];
        
        if (uuidMatch && majorMatch && minorMatch) {
            [filteredBeacons addObject:beacon];
        }
    }
    
    return filteredBeacons;
}

- (void)sendLocalNotification:(NSString *)title body:(NSString *)body {
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.title = title;
    content.body = body;
    content.sound = [UNNotificationSound defaultSound];
    
    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:1 repeats:NO];
    
    NSString *identifier = [NSString stringWithFormat:@"beacon_notification_%f", [[NSDate date] timeIntervalSince1970]];
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:identifier content:content trigger:trigger];
    
    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"Notification error: %@", error.localizedDescription);
        }
    }];
}

@end