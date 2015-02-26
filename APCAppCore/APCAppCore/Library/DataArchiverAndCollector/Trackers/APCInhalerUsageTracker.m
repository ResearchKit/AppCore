//
//  APCInhalerUsageTracker.m
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCInhalerUsageTracker.h"
#import <HKHealthStore+APCExtensions.h>
static NSString *const kCSVFilename  = @"data.csv";
@implementation APCInhalerUsageTracker

-(instancetype)initWithIdentifier:(NSString *)identifier{
    self = [super initWithIdentifier:identifier];
    self.csvFilename = kCSVFilename;
    return self;
}

//does nothing in this case because updates are provided via HK background delivery
-(void)startTracking{
    [super startTracking];
}

- (NSArray *)columnNames{
    return @[@"Date,Time,Inhaler Use"];
}

@end
