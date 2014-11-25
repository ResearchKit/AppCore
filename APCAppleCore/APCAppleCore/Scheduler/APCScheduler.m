//
//  Scheduler.m
//  APCAppleCore
//
//  Created by Justin Warmkessel on 8/27/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//


#import "APCScheduler.h"
#import "APCAppleCore.h"

@interface APCScheduler()
@property  (weak, nonatomic)     APCDataSubstrate        *dataSubstrate;
@property  (strong, nonatomic)   NSManagedObjectContext  *scheduleMOC;
@property  (nonatomic) BOOL isUpdating;
@property  (nonatomic, strong) NSDate * referenceDate;
@end

@implementation APCScheduler

- (instancetype)initWithDataSubstrate: (APCDataSubstrate*) dataSubstrate
{
    self = [super init];
    if (self) {
        self.dataSubstrate = dataSubstrate;
        self.scheduleMOC = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        self.scheduleMOC.parentContext = self.dataSubstrate.persistentContext;
    }
    return self;
}

- (void)updateScheduledTasksIfNotUpdating: (BOOL) today
{
    if (!self.isUpdating) {
        self.isUpdating = YES;
        self.referenceDate = today ? [NSDate todayAtMidnight] : [NSDate tomorrowAtMidnight];
        [self updateScheduledTasks];
    }
}
- (void)setReferenceDate:(NSDate *)referenceDate
{
    _referenceDate = referenceDate;
    NSLog(@"REFERENCE DATE FOR Scheduler: %@", referenceDate);
}

- (void) updateScheduledTasks
{
    [self.scheduleMOC performBlock:^{
        
        //STEP 1: Update inActive property of schedules based on endOn date.
        [self updateSchedulesAsInactiveIfNecessary];
        
        //STEP 2: Read active schedules: inActive == NO && (startOn == nil || startOn <= currentTime)
//        NSArray * activeSchedules = [self readActiveSchedules];
        
        //STEP 3: Delete all incomplete tasks for based on reference date (along with clearing notifications)
        
        //STEP 4: Generate new scheduledTasks based on the active schedules
        
    }];
}

/*********************************************************************************/
#pragma mark - Methods Inside MOC
/*********************************************************************************/

- (void) updateSchedulesAsInactiveIfNecessary
{
    NSFetchRequest * request = [APCSchedule request];
    NSDate * lastEndOnDate = [NSDate startOfDay:self.referenceDate];
    request.predicate = [NSPredicate predicateWithFormat:@"endOn <= %@", lastEndOnDate];
    NSError * error;
    NSArray * array = [self.scheduleMOC executeFetchRequest:request error:&error];
    [error handle];
    [array enumerateObjectsUsingBlock:^(APCSchedule * schedule, NSUInteger idx, BOOL *stop) {
        schedule.inActive = @(YES);
        NSError * saveError;
        [schedule saveToPersistentStore:&saveError];
        [saveError handle];
    }];
}

- (NSArray*) readActiveSchedules
{
    NSFetchRequest * request = [APCSchedule request];
    NSDate * lastStartOnDate = [NSDate startOfTomorrow:self.referenceDate];
    request.predicate = [NSPredicate predicateWithFormat:@"(inActive == nil || inActive == %@) && (startOn == nil || startOn < %@)", @(NO), lastStartOnDate];
    NSError * error;
    NSArray * array = [self.scheduleMOC executeFetchRequest:request error:&error];
    [error handle];
    return array.count ? array : nil;
}

- (void) deleteAllIncompleteScheduledTasksForReferenceDate
{
    
}

@end
