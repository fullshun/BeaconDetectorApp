#import <Foundation/Foundation.h>

@interface BeaconDetection : NSObject <NSCoding>

@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, strong) NSNumber *major;
@property (nonatomic, strong) NSNumber *minor;
@property (nonatomic, strong) NSDate *detectedAt;
@property (nonatomic, assign) NSInteger rssi;
@property (nonatomic, assign) double accuracy;

- (instancetype)initWithUUID:(NSString *)uuid major:(NSNumber *)major minor:(NSNumber *)minor detectedAt:(NSDate *)detectedAt rssi:(NSInteger)rssi accuracy:(double)accuracy;
- (NSDictionary *)toDictionary;
+ (instancetype)fromDictionary:(NSDictionary *)dictionary;

@end