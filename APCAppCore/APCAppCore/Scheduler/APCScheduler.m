// 
//  APCScheduler.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 

#import "APCScheduler.h"
#import "APCAppCore.h"

@interface APCScheduler()
@property  (weak, nonatomic)     APCDataSubstrate        *dataSubstrate;
@property  (strong, nonatomic)   NSManagedObjectContext  *scheduleMOC;
@property  (nonatomic) BOOL isUpdating;
@property  (nonatomic, strong) NSDate * referenceDate;
@property (nonatomic, copy) void (^completionBlock)(NSError * error);
@end

@implementation APCScheduler

- (instancetype)initWithDataSubstrate: (APCDataSubstrate*) dataSubstrate
{
    self = [super init];
    if (self) {
        self.dataSubstrate = dataSubstrate;
        self.scheduleMOC = self.dataSubstrate.persistentContext;
    }
    return self;
}

- (void)updateScheduledTasksIfNotUpdating: (BOOL) today OnCompletion:(void (^)(NSError * error))completionBlock
{
    self.completionBlock = completionBlock;
    if (!self.isUpdating) {
        self.isUpdating = YES;
        self.referenceDate = today ? [NSDate todayAtMidnight] : [NSDate tomorrowAtMidnight];
        [self updateScheduledTasks];
    }
}

- (void) updateScheduledTasks
{
    [self.scheduleMOC performBlock:^{
        
        //STEP 1: Update inActive property of schedules based on endOn date.
        [self updateSchedulesAsInactiveIfNecessary];
        
        //STEP 2: Delete all incomplete tasks for based on reference date
        [self deleteAllIncompleteScheduledTasksForReferenceDate];
        
        //STEP 3: Generate new scheduledTasks based on the active schedules
        [self generateScheduledTasksBasedOnActiveSchedules];
        
        self.isUpdating = NO;
        if (self.completionBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                APCLogEventWithData(kSchedulerEvent, (@{@"event_detail":[NSString stringWithFormat:@"Updated Schedule For %@", self.referenceDate]}));
                self.completionBlock(nil);
            });
        }
        
    }];
}

/*********************************************************************************/
#pragma mark - Methods Inside MOC
/*********************************************************************************/
- (void) updateSchedulesAsInactiveIfNecessary
{
    NSFetchRequest * request = [APCSchedule request];
    NSDate * lastEndOnDate = [NSDate startOfDay:self.referenceDate];
    request.predicate = [NSPredicate predicateWithFormat:@"endsOn <= %@", lastEndOnDate];
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

- (void) deleteAllIncompleteScheduledTasksForReferenceDate
{
    NSFetchRequest * request = [APCScheduledTask request];
    NSDate * startOfDay = [NSDate startOfDay:self.referenceDate];
    NSDate * endOfDay = [NSDate endOfDay:self.referenceDate];
    request.predicate = [NSPredicate predicateWithFormat:@"(completed == nil || completed == %@) && startOn >= %@ && startOn <= %@", @(NO), startOfDay, endOfDay];
    NSError * error;
    NSMutableArray * mutableArray = [[self.scheduleMOC executeFetchRequest:request error:&error] mutableCopy];
    [error handle];
    while (mutableArray.count) {
        APCScheduledTask * task = [mutableArray lastObject];
        [mutableArray removeLastObject];
        [task deleteScheduledTask];
    }
}

- (void) generateScheduledTasksBasedOnActiveSchedules
{
    NSArray * activeSchedules = [self readActiveSchedules];
    [activeSchedules enumerateObjectsUsingBlock:^(APCSchedule * schedule, NSUInteger idx, BOOL *stop) {
        [self generateScheduledTasksForSchedule:schedule];
    }];
}

- (NSArray*) readActiveSchedules
{
    NSFetchRequest * request = [APCSchedule request];
    NSDate * lastStartOnDate = [NSDate startOfTomorrow:self.referenceDate];
    request.predicate = [NSPredicate predicateWithFormat:@"(inActive == nil || inActive == %@) && (startsOn == nil || startsOn < %@)", @(NO), lastStartOnDate];
    NSError * error;
    NSArray * array = [self.scheduleMOC executeFetchRequest:request error:&error];
    [error handle];
    return array.count ? array : nil;
}

- (void) generateScheduledTasksForSchedule: (APCSchedule*) schedule
{
    APCTask * task = [APCTask taskWithTaskID:schedule.taskID inContext:self.scheduleMOC];
    NSAssert(task,@"Task is nil");
    if (schedule.isOneTimeSchedule) {
        [self createScheduledTask:schedule task:task startOn:[NSDate startOfDay:self.referenceDate]];
    }
    else
    {
        APCScheduleExpression * scheduleExpression = schedule.scheduleExpression;
        NSEnumerator*   enumerator = [scheduleExpression enumeratorBeginningAtTime:[NSDate startOfDay:self.referenceDate] endingAtTime:[NSDate startOfTomorrow:self.referenceDate]];
        NSDate * startOnDate;
        while ((startOnDate = enumerator.nextObject))
        {
            [self createScheduledTask:schedule task:task startOn:startOnDate];
        }
    }

}

- (void) createScheduledTask:(APCSchedule*) schedule task: (APCTask*) task startOn: (NSDate*) startOn
{
    //Don't create duplicates
    if (! [APCScheduledTask scheduledTaskForStartOnDate:startOn schedule:schedule inContext:self.scheduleMOC]) {
        APCScheduledTask * createdScheduledTask = [APCScheduledTask newObjectForContext:self.scheduleMOC];
        createdScheduledTask.startOn = startOn;
        
        //TODO: Change the end on date
        createdScheduledTask.endOn = [NSDate endOfDay:self.referenceDate];
        createdScheduledTask.generatedSchedule = schedule;
        createdScheduledTask.task = task;
        NSError * saveError;
        [createdScheduledTask saveToPersistentStore:&saveError];
        [saveError handle];
    }

}

@end
