// 
//  APCScheduledTask+AddOn.m 
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
//
 
#import "APCScheduledTask+AddOn.h"
#import "APCAppCore.h"
#import "APCDateRange.h"

static NSInteger kSecondsPerMinute = 60;
static NSInteger kDefaultReminderOffset = -15;

static NSString * const kScheduledTaskIDKey = @"scheduledTaskID";

@implementation APCScheduledTask (AddOn)

- (void)completeScheduledTask
{
    self.completed = @(YES);
    
    //Turn off one time schedule
    if ([self.generatedSchedule isOneTimeSchedule])
    {
        self.generatedSchedule.inActive = @(YES);
    }
    NSError * saveError;
    [self saveToPersistentStore:&saveError];
    APCLogError2 (saveError);
}

- (void) deleteScheduledTask
{
    [self clearCurrentReminderIfNecessary];
    [self.managedObjectContext deleteObject:self];
    NSError * saveError;
    [self saveToPersistentStore:&saveError];
    APCLogError2 (saveError);
}

- (BOOL)removeScheduledTask:(NSError **)taskError
{
    BOOL deleteSuccess = NO;
    
    [self clearCurrentReminderIfNecessary];
    
    [self.managedObjectContext deleteObject:self];
    
    NSError *coreDataError = nil;
    deleteSuccess = [self saveToPersistentStore:&coreDataError];
    
    if (!deleteSuccess) {
        APCLogError2(coreDataError);
    }
    
    *taskError = coreDataError;
    
    return deleteSuccess;
}

- (NSString *)completeByDateString
{
    return [self.endOn friendlyDescription];
}

- (APCResult *)lastResult
{
    APCResult * retValue = nil;
    if (self.results.count == 1) {
        retValue = [self.results anyObject];
    }
    else if(self.results.count > 1)
    {
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"endDate" ascending:NO];
        NSArray * sortedArray = [self.results sortedArrayUsingDescriptors:@[sortDescriptor]];
        retValue = [sortedArray firstObject];
    }
    return  retValue;
}

+ (NSDictionary*) APCActivityVCScheduledTasksInContext: (NSManagedObjectContext*) context
{
    NSArray * array1 = [self getTodaysTaskInContext:context];
    NSArray * array2 = [self getYesterdaysIncompleteTaskInContext:context];
    
    NSMutableDictionary * finalDict = [NSMutableDictionary dictionary];
    if (array1.count) {
        finalDict[@"today"] = array1;
    }
    if (array2.count) {
        finalDict[@"yesterday"] = array2;
    }
    return finalDict.count ? finalDict : nil;
}

+ (NSArray *) getTodaysTaskInContext: (NSManagedObjectContext*) context {
    NSArray * array = [self allScheduledTasksForDateRange:[APCDateRange todayRange] completed:nil inContext:context];
    //If there are no today's activities, generate them
    if (array.count == 0) {
        [((APCAppDelegate*) [UIApplication sharedApplication].delegate).dataMonitor.scheduler updateScheduledTasksIfNotUpdatingWithRange:kAPCSchedulerDateRangeToday];
        array = [self allScheduledTasksForDateRange:[APCDateRange todayRange] completed:nil inContext:context];
    }
    return array.count ? array : nil;
    
}

+ (NSArray*) getYesterdaysIncompleteTaskInContext: (NSManagedObjectContext*) context {
    NSArray * array = [self allScheduledTasksForDateRange:[APCDateRange yesterdayRange] completed:@NO inContext:context];
    //If there are no yesterday's activities and there are completed activities in the past, generate yesterday's activities
    if (array.count == 0) {
        if ([self userHasCompletedActivitiesInThePastInContext:context]) {
            [((APCAppDelegate*) [UIApplication sharedApplication].delegate).dataMonitor.scheduler updateScheduledTasksIfNotUpdatingWithRange:kAPCSchedulerDateRangeYesterday];
            array = [self allScheduledTasksForDateRange:[APCDateRange yesterdayRange] completed:@NO inContext:context];
        }
    }
    NSArray * filteredArray = [self filterYesterdayIncompleteScheduledTasksByEndDate:array];
    return filteredArray.count ? filteredArray : nil;
}

+ (NSArray*) filterYesterdayIncompleteScheduledTasksByEndDate: (NSArray*) scheduledTasksArray {
    
    NSMutableArray * filteredArray = [NSMutableArray array];
    NSDate * yesterdaysEndDate = [NSDate endOfDay:[NSDate yesterdayAtMidnight]];
    for (APCScheduledTask * scheduledTask in scheduledTasksArray) {
        if (scheduledTask.endOn <= yesterdaysEndDate) {
            [filteredArray addObject:scheduledTask];
        }
    }
    return filteredArray.count ? filteredArray : nil;
}

//If completed is nil then no filtering on completion, else the result will be filtered by completed value
+ (NSArray *)allScheduledTasksForDateRange: (APCDateRange*) dateRange completed: (NSNumber*) completed inContext: (NSManagedObjectContext*) context
{
    NSFetchRequest * request = [APCScheduledTask request];
    
    NSPredicate * datePredicate = [NSPredicate predicateWithFormat:@"endOn > %@", dateRange.startDate];
    NSPredicate * completionPrediate = nil;
    if (completed != nil) {
        completionPrediate = [completed isEqualToNumber:@YES] ? [NSPredicate predicateWithFormat:@"completed == %@", completed] :[NSPredicate predicateWithFormat:@"completed == nil ||  completed == %@", completed] ;
    }
    
    NSPredicate * finalPredicate = completionPrediate ? [NSCompoundPredicate andPredicateWithSubpredicates:@[datePredicate, completionPrediate]] : datePredicate;
    request.predicate = finalPredicate;
    
    NSSortDescriptor *titleSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"task.taskTitle" ascending:YES];
    request.sortDescriptors = @[titleSortDescriptor];
    
    NSError * error;
    NSArray * array = [context executeFetchRequest:request error:&error];
    APCLogError2 (error);

    
    NSMutableArray * filteredArray = [NSMutableArray array];
    
    for (APCScheduledTask * scheduledTask in array) {
        if ([scheduledTask.dateRange compare:dateRange] != kAPCDateRangeComparisonOutOfRange) {
            [filteredArray addObject:scheduledTask];
        }
    }
    
    NSArray * finalArray = filteredArray;
    //Filtering multiday tasks that were completed yesterday or older
    if (completed == nil) {
        finalArray = [self filterTasksCompletedYesterdayOrOlder:filteredArray];
    }
    
    return finalArray.count ? finalArray : nil;
}

+ (BOOL) userHasCompletedActivitiesInThePastInContext: (NSManagedObjectContext*) context {
    
    NSFetchRequest * request = [APCScheduledTask request];
    request.predicate = [NSPredicate predicateWithFormat:@"completed == %@ && endOn < %@", @YES, [NSDate yesterdayAtMidnight]];
    NSError * error;
    NSUInteger count = [context countForFetchRequest:request error:&error];
    APCLogError2 (error);
    return (count > 0) ? YES : NO;
}

+ (instancetype) scheduledTaskForStartOnDate: (NSDate *) startOn schedule: (APCSchedule*) schedule inContext: (NSManagedObjectContext*) context
{
    NSFetchRequest * request = [APCScheduledTask request];
    request.predicate = [NSPredicate predicateWithFormat:@"startOn == %@ && generatedSchedule == %@", startOn, schedule];
    NSError * error;
    NSArray * array = [context executeFetchRequest:request error:&error];
    APCLogError2 (error);
    return array.count ? [array firstObject] : nil;
}

+ (NSArray*) filterTasksCompletedYesterdayOrOlder: (NSArray*) scheduledTasksArray
{
    NSMutableArray * filteredArray = [NSMutableArray array];
    NSDate * todayAtMidnight = [NSDate todayAtMidnight];
    [scheduledTasksArray enumerateObjectsUsingBlock:^(APCScheduledTask * obj, NSUInteger __unused idx, BOOL * __unused stop) {
        
        if ([obj.completed isEqualToNumber:@YES]) {
            if (obj.lastResult.endDate.timeIntervalSinceReferenceDate >= todayAtMidnight.timeIntervalSinceReferenceDate) {
                [filteredArray addObject:obj];
            }
        }
        else
        {
            [filteredArray addObject:obj];
        }
    }];
    return filteredArray;
}

/*********************************************************************************/
#pragma mark - Counts
/*********************************************************************************/
+ (NSUInteger)countOfAllScheduledTasksTodayInContext: (NSManagedObjectContext*) context {
    NSArray * array = [self allScheduledTasksForDateRange:[APCDateRange todayRange] completed:nil inContext:context];
    return array.count;
}

+ (NSUInteger)countOfAllCompletedTasksTodayInContext: (NSManagedObjectContext*) context {
    NSArray * array = [self allScheduledTasksForDateRange:[APCDateRange todayRange] completed:@YES inContext:context];
    return array.count;
}


/*********************************************************************************/
#pragma mark - Life Cycle Methods
/*********************************************************************************/
- (void)awakeFromInsert
{
    [super awakeFromInsert];
    [self setPrimitiveValue:[NSDate date] forKey:@"createdAt"];
    [self setPrimitiveValue:[NSUUID UUID].UUIDString forKey:@"uid"];
}

- (void)willSave
{
    [self setPrimitiveValue:[NSDate date] forKey:@"updatedAt"];
}


/*********************************************************************************/
#pragma mark - Local Notification
/*********************************************************************************/

- (void)scheduleReminderIfNecessary
{
    if ([self.generatedSchedule.shouldRemind boolValue]) {
        [self clearCurrentReminderIfNecessary];
        // Schedule the notification
        UILocalNotification* localNotification = [[UILocalNotification alloc] init];
        NSTimeInterval reminderOffset = self.generatedSchedule.reminderOffset ? (NSTimeInterval)[self.generatedSchedule.reminderOffset doubleValue] : kDefaultReminderOffset * kSecondsPerMinute;
        localNotification.fireDate = [self.startOn dateByAddingTimeInterval: reminderOffset];
        localNotification.alertBody = self.generatedSchedule.reminderMessage;
        
        //TODO: figure out how the badge numbers are going to be set.
        //localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
        
        NSMutableDictionary *notificationInfo = [[NSMutableDictionary alloc] init];
        notificationInfo[kScheduledTaskIDKey] = self.uid;
        localNotification.userInfo = notificationInfo;
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    }
}


+ (void)clearAllReminders
{
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *eventArray = [app scheduledLocalNotifications];
    [eventArray enumerateObjectsUsingBlock:^(UILocalNotification * obj, NSUInteger __unused idx, BOOL * __unused stop) {
        NSDictionary *userInfoCurrent = obj.userInfo;
        if (userInfoCurrent[kScheduledTaskIDKey]) {
            [app cancelLocalNotification:obj];
        }
    }];
}

- (void)clearCurrentReminderIfNecessary
{
    UILocalNotification * currentReminder = [self currentReminder];
    UIApplication *app = [UIApplication sharedApplication];
    if (currentReminder) {
        [app cancelLocalNotification:currentReminder];
    }
}

- (UILocalNotification *) currentReminder
{
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *eventArray = [app scheduledLocalNotifications];
    __block UILocalNotification * retValue;
    [eventArray enumerateObjectsUsingBlock:^(UILocalNotification * obj, NSUInteger  __unused dx, BOOL * __unused stop) {
        NSDictionary *userInfoCurrent = obj.userInfo;
        if ([userInfoCurrent[kScheduledTaskIDKey] isEqualToString:self.uid]) {
            retValue = obj;
        }
    }];
    return retValue;
}

/*********************************************************************************/
#pragma mark - Multiday Tasks
/*********************************************************************************/
- (BOOL) isMultiDayTask {
    NSTimeInterval interval = [self.endOn timeIntervalSinceDate:self.startOn];
    return (interval > (24 * 60 * 60) + 3);
}

- (APCDateRange*) dateRange {
    if (self.startOn == nil || self.endOn == nil) {
        return nil;
    }
    return [[APCDateRange alloc] initWithStartDate:self.startOn endDate:self.endOn];
}

- (void)setDateRange:(APCDateRange *)dateRange {
    self.startOn = dateRange.startDate;
    self.endOn = dateRange.endDate;
}

@end
