//
//  APCHealthKitDataCollector.m
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCHealthKitDataCollector.h"

static NSString *const kHealthKitDataCollectorFilename = @"data.csv";

@implementation APCHealthKitDataCollector

- (instancetype)initWithIdentifier:(NSString *)identifier
{
    self = [super initWithIdentifier:identifier];
    
    if (self) {
        _csvFilename = kHealthKitDataCollectorFilename;
    }
    
    return self;
}

/**
  * This does nothing, because the data is being provided by
  * the HealthKit observer query.
  */
- (void)startTracking
{
    [super startTracking];
}

- (NSArray *)columnNames
{
    return @[@"datetime,type,value"];
}

@end
