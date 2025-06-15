#import "BeaconDataManager.h"

static NSString *const kBeaconDetectionsKey = @"BeaconDetections";

@implementation BeaconDataManager

+ (instancetype)sharedManager {
    static BeaconDataManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[BeaconDataManager alloc] init];
    });
    return sharedManager;
}

- (void)saveBeaconDetection:(BeaconDetection *)detection {
    NSMutableArray *detections = [self getAllDetections].mutableCopy;
    if (!detections) {
        detections = [[NSMutableArray alloc] init];
    }
    
    [detections addObject:detection];
    
    NSMutableArray *detectionDictionaries = [[NSMutableArray alloc] init];
    for (BeaconDetection *det in detections) {
        [detectionDictionaries addObject:[det toDictionary]];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:detectionDictionaries forKey:kBeaconDetectionsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSArray<BeaconDetection *> *)getAllDetections {
    NSArray *detectionDictionaries = [[NSUserDefaults standardUserDefaults] objectForKey:kBeaconDetectionsKey];
    if (!detectionDictionaries) {
        return @[];
    }
    
    NSMutableArray *detections = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in detectionDictionaries) {
        BeaconDetection *detection = [BeaconDetection fromDictionary:dict];
        [detections addObject:detection];
    }
    
    // 日時順で降順ソート（新しいものが先）
    [detections sortUsingComparator:^NSComparisonResult(BeaconDetection *obj1, BeaconDetection *obj2) {
        return [obj2.detectedAt compare:obj1.detectedAt];
    }];
    
    return detections;
}

- (void)clearAllDetections {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kBeaconDetectionsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end