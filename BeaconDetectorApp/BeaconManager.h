#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <UserNotifications/UserNotifications.h>
#import "BeaconDataManager.h"
#import "BeaconDetection.h"

@protocol BeaconManagerDelegate <NSObject>

- (void)didRangeBeacons:(NSArray<CLBeacon *> *)beacons inRegion:(CLBeaconRegion *)region;
- (void)didEnterRegion:(CLRegion *)region;
- (void)didExitRegion:(CLRegion *)region;
- (void)didFailWithError:(NSError *)error;
- (void)detectionStatusChanged:(BOOL)isDetecting;

@end

@interface BeaconManager : NSObject <CLLocationManagerDelegate>

@property (nonatomic, weak) id<BeaconManagerDelegate> delegate;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, assign) BOOL isDetecting;

+ (instancetype)sharedManager;
- (void)startRangingBeaconsWithUUID:(NSString *)uuidString major:(NSNumber *)major minor:(NSNumber *)minor identifier:(NSString *)identifier;
- (void)stopRangingBeacons;
- (void)requestLocationPermission;
- (void)requestNotificationPermission;

@end