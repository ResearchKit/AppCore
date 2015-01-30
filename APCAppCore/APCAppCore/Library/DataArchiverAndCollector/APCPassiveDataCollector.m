//
//  APCPassiveDataCollector.m
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCPassiveDataCollector.h"

@interface APCPassiveDataCollector () <APCDataTrackerDelegate>
@property (nonatomic, strong) NSMutableDictionary * registeredTrackers;
@end

@implementation APCPassiveDataCollector

- (instancetype)init
{
    self = [super init];
    if (self) {
        _registeredTrackers = [NSMutableDictionary dictionary];
        //Setup default directory if it does not exist
    }
    return self;
}

- (void)addTracker:(APCDataTracker *)tracker
{
    NSAssert(self.registeredTrackers[tracker.identifier] == nil, @"Tracker with the same identifier already exists");
    self.registeredTrackers[tracker.identifier] = tracker;
    tracker.delegate = self;
    [self createLogFileIfDoesntExist];
}

- (void) createLogFileIfDoesntExist
{
    //Create folder and CSV file if it does not exist
    //Add info.json
}

- (void)flush:(NSString *)trackerIdentifier
{
    
}
/*********************************************************************************/
#pragma mark - APC Tracker Delegate
/*********************************************************************************/
- (void) APCDataTracker:(APCDataTracker *)tracker hasNewData:(NSArray *)dataArray
{
    //Write array to CSV file
    //Verify if the the data need to be flushed
}

@end
