//
//  APCGenericDataTracker.m
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCDataTracker.h"

long long kKBPerMB = 1024;
long long kBytesPerKB = 1024;

NSUInteger kSecsPerMin = 60;
NSUInteger kMinsPerHour = 60;
NSUInteger kHoursPerDay = 24;
NSUInteger kDaysPerWeek = 7;

@interface APCDataTracker ()
@property (nonatomic, strong) NSString * identifier;
@end

@implementation APCDataTracker

-(instancetype)initWithIdentifier:(NSString *)identifier
{
    self = [super init];
    if (self) {
        NSAssert(identifier.length > 0, @"Valid identifier missing");
        _identifier = identifier;
    }
    return self;
}

/*********************************************************************************/
#pragma mark - Abstract Implementations
/*********************************************************************************/

- (long long)sizeThreshold
{
    if (_sizeThreshold == 0) {
        _sizeThreshold = 1 * kKBPerMB * kBytesPerKB;
    }
    return _sizeThreshold;
}

- (NSTimeInterval)stalenessInterval
{
    if (_stalenessInterval == 0) {
        _stalenessInterval = 1 * kDaysPerWeek * kHoursPerDay * kMinsPerHour * kSecsPerMin;
    }
    return _stalenessInterval;
}

- (NSArray*) columnNames
{
    NSAssert(NO, @"Column names missing");
    return nil;
}

@end
