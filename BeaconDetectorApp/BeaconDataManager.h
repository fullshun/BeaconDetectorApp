#import <Foundation/Foundation.h>
#import "BeaconDetection.h"

@interface BeaconDataManager : NSObject

+ (instancetype)sharedManager;
- (void)saveBeaconDetection:(BeaconDetection *)detection;
- (NSArray<BeaconDetection *> *)getAllDetections;
- (void)clearAllDetections;

@end