//
//  APCHKCumulativeQuantityTracker.m
//  APCAppCore
//
//  Created by Dhanush Balachandran on 2/2/15.
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCHKCumulativeQuantityTracker.h"
#import "APCAppCore.h"

static NSString *const kAnchorDateFilename = @"anchorDate";

@interface APCHKCumulativeQuantityTracker ()
{
    NSDate * _anchorDate;
}

@property (nonatomic, strong) NSDateComponents * interval;
@property (nonatomic, strong) HKQuantityType * quantityType;
@property (nonatomic, strong) NSDate * anchorDate;

@property (nonatomic, readonly) NSString* anchorDateFilePath;

@end

@implementation APCHKCumulativeQuantityTracker

- (instancetype) initWithIdentifier:(NSString *)identifier quantityTypeIdentifier: (NSString*) quantityTypeIdentifier interval: (NSDateComponents*) interval
{
    self = [super initWithIdentifier:identifier];
    if (self) {
        _quantityType = [HKObjectType quantityTypeForIdentifier:quantityTypeIdentifier];
        _interval = interval;
        
    }
    return self;
}

- (NSString *)anchorDateFilePath
{
    return [self.folder stringByAppendingPathComponent:kAnchorDateFilename];
}

- (void)setAnchorDate:(NSDate *)anchorDate
{
    _anchorDate = anchorDate;
    [self writeAnchorDate:anchorDate];
}

- (NSDate *)anchorDate
{
    if (!_anchorDate) {
        if (self.folder) {
            if ([[NSFileManager defaultManager] fileExistsAtPath:self.anchorDateFilePath]) {
                NSError * error;
                NSString * anchorDateString = [NSString stringWithContentsOfFile:self.anchorDateFilePath encoding:NSUTF8StringEncoding error:&error];
                APCLogError2(error);
                _anchorDate = [NSDate dateWithTimeIntervalSinceReferenceDate:[anchorDateString doubleValue]];
            }
            else
            {
                _anchorDate = [NSDate date];
                [self writeAnchorDate:_anchorDate];
            }
        }
        
    }
    return _anchorDate;
}

- (void) writeAnchorDate: (NSDate*) date
{
    NSString * anchorDateString = [NSString stringWithFormat:@"%0.0f",[date timeIntervalSinceReferenceDate]];
    [APCPassiveDataCollector createOrReplaceString:anchorDateString toFile:self.anchorDateFilePath];
}

- (NSArray *)columnNames
{
    return @[@"startDate", @"endDate", @"dataType", @"data"];
}

@end
