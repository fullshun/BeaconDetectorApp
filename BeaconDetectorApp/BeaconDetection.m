#import "BeaconDetection.h"

@implementation BeaconDetection

- (instancetype)initWithUUID:(NSString *)uuid major:(NSNumber *)major minor:(NSNumber *)minor detectedAt:(NSDate *)detectedAt rssi:(NSInteger)rssi accuracy:(double)accuracy {
    self = [super init];
    if (self) {
        self.uuid = uuid;
        self.major = major;
        self.minor = minor;
        self.detectedAt = detectedAt;
        self.rssi = rssi;
        self.accuracy = accuracy;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.uuid = [coder decodeObjectForKey:@"uuid"];
        self.major = [coder decodeObjectForKey:@"major"];
        self.minor = [coder decodeObjectForKey:@"minor"];
        self.detectedAt = [coder decodeObjectForKey:@"detectedAt"];
        self.rssi = [coder decodeIntegerForKey:@"rssi"];
        self.accuracy = [coder decodeDoubleForKey:@"accuracy"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.uuid forKey:@"uuid"];
    [coder encodeObject:self.major forKey:@"major"];
    [coder encodeObject:self.minor forKey:@"minor"];
    [coder encodeObject:self.detectedAt forKey:@"detectedAt"];
    [coder encodeInteger:self.rssi forKey:@"rssi"];
    [coder encodeDouble:self.accuracy forKey:@"accuracy"];
}

- (NSDictionary *)toDictionary {
    return @{
        @"uuid": self.uuid ?: @"",
        @"major": self.major ?: @0,
        @"minor": self.minor ?: @0,
        @"detectedAt": @([self.detectedAt timeIntervalSince1970]),
        @"rssi": @(self.rssi),
        @"accuracy": @(self.accuracy)
    };
}

+ (instancetype)fromDictionary:(NSDictionary *)dictionary {
    NSString *uuid = dictionary[@"uuid"];
    NSNumber *major = dictionary[@"major"];
    NSNumber *minor = dictionary[@"minor"];
    NSDate *detectedAt = [NSDate dateWithTimeIntervalSince1970:[dictionary[@"detectedAt"] doubleValue]];
    NSInteger rssi = [dictionary[@"rssi"] integerValue];
    double accuracy = [dictionary[@"accuracy"] doubleValue];
    
    return [[BeaconDetection alloc] initWithUUID:uuid major:major minor:minor detectedAt:detectedAt rssi:rssi accuracy:accuracy];
}

@end