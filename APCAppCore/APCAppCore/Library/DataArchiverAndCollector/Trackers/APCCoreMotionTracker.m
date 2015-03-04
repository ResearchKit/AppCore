//
//  APCCoreMotionTracker.m
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCCoreMotionTracker.h"
#import "CMMotionActivity+Helper.h"


static NSString *const kLastUsedTimeKey = @"APCPassiveCoreMotionLastTrackedEndDate";
static NSInteger const kNumberOfDaysBack = 8;
@implementation APCCoreMotionTracker

- (void) startTracking

{
    self.motionActivityManager = [[CMMotionActivityManager alloc] init];
    
}


- (void) updateTracking
{
    NSDate *lastTrackedEndDate = [[NSUserDefaults standardUserDefaults] objectForKey:kLastUsedTimeKey];
    
    if (!lastTrackedEndDate) {
        lastTrackedEndDate = [self maximumNumberOfDaysBack];
        
    }
    
    [self.motionActivityManager queryActivityStartingFromDate:lastTrackedEndDate
                                                       toDate:[NSDate date]
                                                      toQueue:[NSOperationQueue new]
                                                  withHandler:^(NSArray *activities, NSError * __unused error) {
                                                      
                                                      
                                                      [self.delegate APCDataTracker:self hasNewData:activities];
                                                      
                                                      [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kLastUsedTimeKey];
                                                  }];
}

- (NSArray *) columnNames
{
    return [CMMotionActivity csvColumnNames];
}

#pragma mark - Helper methods
         
 - (NSDate *) maximumNumberOfDaysBack {
     NSInteger               numberOfDaysBack = kNumberOfDaysBack * -1;
     NSDateComponents        *components = [[NSDateComponents alloc] init];
     
     [components setDay:numberOfDaysBack];
     
     NSDate                  *date = [[NSCalendar currentCalendar] dateByAddingComponents:components
                                                                                           toDate:[NSDate date]
                                                                                          options:0];
     
     return date;
 }

@end
