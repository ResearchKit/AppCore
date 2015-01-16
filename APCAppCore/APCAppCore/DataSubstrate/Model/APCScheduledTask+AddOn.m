// 
//  APCScheduledTask+AddOn.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
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
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"updatedAt" ascending:NO];
        NSArray * sortedArray = [self.results sortedArrayUsingDescriptors:@[sortDescriptor]];
        retValue = [sortedArray firstObject];
    }
    return  retValue;
}

+ (NSArray*) APCActivityVCScheduledTasksInContext: (NSManagedObjectContext*) context
{
    //Ask tasks for today and yesterday range
    NSArray * array1 = [self allScheduledTasksForDateRange:[APCDateRange todayRange] completed:nil inContext:context];
    NSArray * array2 = [self allScheduledTasksForDateRange:[APCDateRange yesterdayRange] completed:@NO inContext:context];
    
    NSMutableArray * finalArray = [NSMutableArray array];
    
    //If there are no today's activities, generate them
    if (array1.count) {
        [finalArray addObjectsFromArray:array1];
    }
    else
    {
        [((APCAppDelegate*) [UIApplication sharedApplication].delegate).dataMonitor.scheduler updateScheduledTasksIfNotUpdatingWithRange:kAPCSchedulerDateRangeToday];
        array1 = [self allScheduledTasksForDateRange:[APCDateRange todayRange] completed:nil inContext:context];
        if (array1.count) [finalArray addObjectsFromArray:array1];
    }
    
    //If there are not yesterday's activities and there are completed activities in the past, generate yesterday's activities
    if (array2.count) {
        [finalArray addObjectsFromArray:array2];
    }
    else
    {
        if ([self userHasCompletedActivitiesInThePastInContext:context]) {
            [((APCAppDelegate*) [UIApplication sharedApplication].delegate).dataMonitor.scheduler updateScheduledTasksIfNotUpdatingWithRange:kAPCSchedulerDateRangeYesterday];
            array2 = [self allScheduledTasksForDateRange:[APCDateRange yesterdayRange] completed:@NO inContext:context];
            if (array2.count) [finalArray addObjectsFromArray:array2];
        }
    }
    return finalArray.count ? finalArray : nil;
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
    
    NSSortDescriptor *dateSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"task.taskTitle" ascending:YES];
    NSSortDescriptor * uidDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"completed" ascending:YES];
    request.sortDescriptors = @[uidDescriptor, dateSortDescriptor];
    
    NSError * error;
    NSArray * array = [context executeFetchRequest:request error:&error];
    APCLogError2 (error);

    
    NSMutableArray * filteredArray = [NSMutableArray array];
    
    for (APCScheduledTask * scheduledTask in array) {
        if ([scheduledTask.dateRange compare:dateRange] != kAPCDateRangeComparisonOutOfRange) {
            [filteredArray addObject:scheduledTask];
        }
    }
    return filteredArray.count ? filteredArray : nil;
}

+ (BOOL) userHasCompletedActivitiesInThePastInContext: (NSManagedObjectContext*) context {
    
    NSFetchRequest * request = [APCScheduledTask request];
    request.predicate = [NSPredicate predicateWithFormat:@"completed == %@ && endOn > %@", @YES, [NSDate yesterdayAtMidnight]];
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
    [eventArray enumerateObjectsUsingBlock:^(UILocalNotification * obj, NSUInteger idx, BOOL *stop) {
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
    [eventArray enumerateObjectsUsingBlock:^(UILocalNotification * obj, NSUInteger idx, BOOL *stop) {
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
