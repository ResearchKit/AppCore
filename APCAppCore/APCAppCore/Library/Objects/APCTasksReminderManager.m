// 
//  APCTasksReminderManager.m 
//  APCAppCore 
// 
// Copyright (c) 2015, Apple Inc. All rights reserved. 
// 
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
// 
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
// 
// 2.  Redistributions in binary form must reproduce the above copyright notice, 
// this list of conditions and the following disclaimer in the documentation and/or 
// other materials provided with the distribution. 
// 
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors 
// may be used to endorse or promote products derived from this software without 
// specific prior written permission. No license is granted to the trademarks of 
// the copyright holders even if such marks are included in this software. 
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE 
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
// 
 
#import "APCTasksReminderManager.h"
#import "APCAppCore.h"
#import "APCConstants.h"

NSString * const kTaskReminderUserInfo = @"CurrentTaskReminder";
NSString * const kTaskReminderUserInfoKey = @"TaskReminderUserInfoKey";

static NSInteger kSecondsPerMinute = 60;
static NSInteger kMinutesPerHour = 60;

NSString * const kTaskReminderMessage = @"Please complete your %@ activities today. Thank you for participating in the %@ study! %@";
NSString * const kTaskReminderDelayMessage = @"Remind me in 1 hour";

@interface APCTasksReminderManager ()

@property (strong, nonatomic) NSMutableDictionary *remindersToSend;
@end

@implementation APCTasksReminderManager

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTasksReminder) name:APCUpdateTasksReminderNotification object:nil];
        self.reminders = [NSMutableArray new];
        self.remindersToSend = [NSMutableDictionary new];
        [self updateTasksReminder];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/*********************************************************************************/
#pragma mark - Task Reminder Queue
/*********************************************************************************/
-(void)manageTaskReminder:(APCTaskReminder *)reminder{
    [self.reminders addObject:reminder];
}

-(NSArray *)reminders{
    return (NSArray *)_reminders;
}

/*********************************************************************************/
#pragma mark - Local Notification Scheduling
/*********************************************************************************/
- (void) updateTasksReminder
{
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        APCAppDelegate * delegate = (APCAppDelegate*)[UIApplication sharedApplication].delegate;
        if (!delegate.dataSubstrate.currentUser.signedIn) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:kTasksReminderDefaultsOnOffKey];
            [self cancelLocalNotificationIfExists];
        }
        else
        {
            if (self.reminderOn) {
                [self createOrUpdateLocalNotification];
            }
            else {
                [self cancelLocalNotificationIfExists];
            }
        }
    });
}

- (UILocalNotification*) existingLocalNotification {
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *eventArray = [app scheduledLocalNotifications];
    __block UILocalNotification * retValue;
    [eventArray enumerateObjectsUsingBlock:^(UILocalNotification * obj, NSUInteger __unused idx, BOOL * __unused stop) {
        NSDictionary *userInfoCurrent = obj.userInfo;
        if ([userInfoCurrent[[self taskReminderUserInfoKey]] isEqualToString:[self taskReminderUserInfo]]) {
            retValue = obj;
        }
    }];
    return retValue;
}

- (void) cancelLocalNotificationIfExists {
    UILocalNotification * notification = [self existingLocalNotification];
    if (notification) {
        UIApplication *app = [UIApplication sharedApplication];
        [app cancelLocalNotification:notification];
        APCLogDebug(@"Cancelled Notification: %@", notification);
    }
}

- (void) createOrUpdateLocalNotification {
    
    [self cancelLocalNotificationIfExists];
    
    // Schedule the notification
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    
    localNotification.fireDate = [self calculateFireDate];
    localNotification.timeZone = [NSTimeZone localTimeZone];
    localNotification.alertBody = [self reminderMessage];
    localNotification.repeatInterval = NSCalendarUnitDay;
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    
    NSMutableDictionary *notificationInfo = [[NSMutableDictionary alloc] init];
    notificationInfo[[self taskReminderUserInfoKey]] = [self taskReminderUserInfo];
    localNotification.userInfo = notificationInfo;
    
    localNotification.category = kTaskReminderDelayCategory;
    
    if (self.remindersToSend.count >0) {
        
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
       
        APCLogEventWithData(kSchedulerEvent, (@{@"event_detail":[NSString stringWithFormat:@"Scheduled Reminder: %@. Body: %@", localNotification, localNotification.alertBody]}));
    }
}

+(NSSet *)taskReminderCategories{
    
    //Add Action for delay reminder
    UIMutableUserNotificationAction *delayReminderAction = [[UIMutableUserNotificationAction alloc] init];
    delayReminderAction.identifier = kDelayReminderIdentifier;
    delayReminderAction.title = NSLocalizedString(kTaskReminderDelayMessage, nil);
    delayReminderAction.activationMode = UIUserNotificationActivationModeBackground;
    delayReminderAction.destructive = NO;
    delayReminderAction.authenticationRequired = NO;
    
    //Add Category for delay reminder
    UIMutableUserNotificationCategory *delayCategory = [[UIMutableUserNotificationCategory alloc] init];
    delayCategory.identifier = kTaskReminderDelayCategory;
    [delayCategory setActions:@[delayReminderAction]
                   forContext:UIUserNotificationActionContextDefault];
    [delayCategory setActions:@[delayReminderAction]
                   forContext:UIUserNotificationActionContextMinimal];
    
    return [NSSet setWithObjects:delayCategory, nil];
    
}

/*********************************************************************************/
#pragma mark - Reminder Parameters
/*********************************************************************************/
-(NSString *)reminderMessage{
    
    NSString *reminders = @"\n";
    //concatenate body of each message with \n
    
    for (APCTaskReminder *taskReminder in self.reminders) {
        if ([self includeTaskInReminder:taskReminder]) {
            reminders = [reminders stringByAppendingString:@"• "];
            reminders = [reminders stringByAppendingString:taskReminder.reminderBody];
            reminders = [reminders stringByAppendingString:@"\n"];
            self.remindersToSend[taskReminder.reminderIdentifier] = taskReminder;
        }else{
            if (self.remindersToSend[taskReminder.reminderIdentifier]) {
                [self.remindersToSend removeObjectForKey:taskReminder.reminderIdentifier];
            }
        }
    }
    
    return [NSString stringWithFormat:kTaskReminderMessage, [self studyName], [self studyName], reminders];;
}

-(NSString *)taskReminderUserInfo{
    return kTaskReminderUserInfo;
}

-(NSString *)taskReminderUserInfoKey{
    return kTaskReminderUserInfoKey;
}

- (NSString *)studyName {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"StudyOverview" ofType:@"json"];
    NSString *JSONString = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
    
    NSError *parseError;
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:[JSONString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&parseError];
    
    if (jsonDictionary) {
        return jsonDictionary[@"disease_name"];
    } else {
        APCLogError2(parseError);
        return @"this study";
    }
}

/*********************************************************************************/
#pragma mark - Reminder Time
/*********************************************************************************/

- (BOOL)reminderOn {
    NSNumber * number = [[NSUserDefaults standardUserDefaults] objectForKey:kTasksReminderDefaultsOnOffKey];
    //Setting up defaults using initialization options
    if (number == nil) {
        APCAppDelegate * delegate = (APCAppDelegate*)[UIApplication sharedApplication].delegate;
        NSNumber * numberDefault = delegate.initializationOptions[kTaskReminderStartupDefaultOnOffKey];
        number = numberDefault?:@YES;
        [[NSUserDefaults standardUserDefaults] setObject:number forKey:kTasksReminderDefaultsOnOffKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    return [number boolValue];
}

- (void)setReminderOn:(BOOL)reminderOn
{
    [self updateReminderOn:reminderOn];
    [self updateTasksReminder];
}

- (void) updateReminderOn: (BOOL) reminderOn
{
    [[NSUserDefaults standardUserDefaults] setObject:@(reminderOn) forKey:kTasksReminderDefaultsOnOffKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)reminderTime {
    NSString * timeString = [[NSUserDefaults standardUserDefaults] objectForKey:kTasksReminderDefaultsTimeKey];
    if (timeString == nil) {
        APCAppDelegate * delegate = (APCAppDelegate*)[UIApplication sharedApplication].delegate;
        NSString * timeDefault = delegate.initializationOptions[kTaskReminderStartupDefaultTimeKey];
        timeString = timeDefault?:@"5:00 PM";
        [[NSUserDefaults standardUserDefaults] setObject:timeString forKey:kTasksReminderDefaultsTimeKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    return timeString;
}

- (void)setReminderTime:(NSString *)reminderTime 
{
    [self updateReminderTime:reminderTime];
    [self updateTasksReminder];
}

- (void)updateReminderTime:(NSString *)reminderTime
{
    NSAssert([[APCTasksReminderManager reminderTimesArray] containsObject:reminderTime], @"reminder time should be in the reminder times array");
    [[NSUserDefaults standardUserDefaults] setObject:reminderTime forKey:kTasksReminderDefaultsTimeKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSDate*) calculateFireDate
{
    NSTimeInterval reminderOffset = ([[APCTasksReminderManager reminderTimesArray] indexOfObject:self.reminderTime]) * kMinutesPerHour * kSecondsPerMinute;
    NSDate *dateToSet = self.remindersToSend.count == 0 ? [[NSDate tomorrowAtMidnight] dateByAddingTimeInterval:reminderOffset] : [[NSDate todayAtMidnight] dateByAddingTimeInterval:reminderOffset];
    return dateToSet;
}

/*********************************************************************************/
#pragma mark - Helper
/*********************************************************************************/
+ (NSArray*) reminderTimesArray {
    static NSArray * timesArray = nil;
    if (timesArray == nil) {
        timesArray = @[
                       @"Midnight",
                       @"1:00 AM",
                       @"2:00 AM",
                       @"3:00 AM",
                       @"4:00 AM",
                       @"5:00 AM",
                       @"6:00 AM",
                       @"7:00 AM",
                       @"8:00 AM",
                       @"9:00 AM",
                       @"10:00 AM",
                       @"11:00 AM",
                       @"Noon",
                       @"1:00 PM",
                       @"2:00 PM",
                       @"3:00 PM",
                       @"4:00 PM",
                       @"5:00 PM",
                       @"6:00 PM",
                       @"7:00 PM",
                       @"8:00 PM",
                       @"9:00 PM",
                       @"10:00 PM",
                       @"11:00 PM"
                       ];
    }
    return timesArray;
}

/*********************************************************************************/
#pragma mark - Task Reminder Inclusion Model
/*********************************************************************************/
-(BOOL)includeTaskInReminder:(APCTaskReminder *)taskReminder{
    BOOL includeTask = NO;
    
    //the reminderIdentifier shall be added to NSUserDefaults only when the task reminder is set to ON
    if (![[NSUserDefaults standardUserDefaults] objectForKey: taskReminder.reminderIdentifier]) {
        //the reminder for this task is off
        return includeTask;
    }
    
    NSArray *completedTasks = [APCTasksReminderManager scheduledTasksForTaskID:taskReminder.taskID completed:@1];
    NSArray *scheduledTasks = [APCTasksReminderManager scheduledTasksForTaskID:taskReminder.taskID completed:nil];
    
    if (completedTasks.count >0 && taskReminder.resultsSummaryKey != nil) {
        for (APCScheduledTask *task in completedTasks) {
            
            //get the result summary for this daily prompt task
            NSString * resultSummary = task.lastResult.resultSummary;
            
            NSDictionary * dictionary = resultSummary ? [NSDictionary dictionaryWithJSONString:resultSummary] : nil;
            
            NSString *result;
            if (dictionary.count > 0) {
                result = [dictionary objectForKey:taskReminder.resultsSummaryKey];
            }
            
            NSArray *results = [[NSArray alloc]initWithObjects:result, nil];
            NSArray *completedTask = [results filteredArrayUsingPredicate:taskReminder.completedTaskPredicate];
            
            if (completedTask.count == 0){
                includeTask = YES;
            }
        }
    }else if(completedTasks.count == 0 && scheduledTasks.count > 0){//if this task has not been completed but was scheduled, include it in the reminder
        includeTask = YES;
    }
    
    return includeTask;
}

//Pass in a taskID
+ (NSArray *)scheduledTasksForTaskID:(NSString *)taskID completed:(NSNumber *)completed
{
   
    APCDateRange *dateRange = [[APCDateRange alloc]initWithStartDate:[NSDate todayAtMidnight] endDate:[NSDate tomorrowAtMidnight]];
    NSManagedObjectContext *context = ((APCAppDelegate *)[UIApplication sharedApplication].delegate).dataSubstrate.mainContext;
    
    NSFetchRequest * request = [APCScheduledTask request];
    request.shouldRefreshRefetchedObjects = YES;
    
    NSPredicate * datePredicate = [NSPredicate predicateWithFormat:@"endOn >= %@ AND task.taskID == %@", dateRange.startDate, taskID];
    
    NSPredicate * completionPredicate = nil;
    if (completed != nil) {
        completionPredicate = [completed isEqualToNumber:@YES] ? [NSPredicate predicateWithFormat:@"completed == %@", completed] :[NSPredicate predicateWithFormat:@"completed == nil ||  completed == %@", completed] ;
    }
    
    NSPredicate * finalPredicate = completionPredicate ? [NSCompoundPredicate andPredicateWithSubpredicates:@[datePredicate, completionPredicate]] : datePredicate;
    request.predicate = finalPredicate;
    
    NSSortDescriptor *titleSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"task.taskTitle" ascending:YES];
    NSSortDescriptor * completedSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"completed" ascending:YES];
    request.sortDescriptors = @[completedSortDescriptor, titleSortDescriptor];
    
    NSError * error;
    NSArray * array = [context executeFetchRequest:request error:&error];
    if (array == nil) {
        APCLogError2 (error);
    }
    
    NSMutableArray * filteredArray = [NSMutableArray array];
    
    for (APCScheduledTask * scheduledTask in array) {
        if ([scheduledTask.dateRange compare:dateRange] != kAPCDateRangeComparisonOutOfRange) {
            [filteredArray addObject:scheduledTask];
        }
    }
    return filteredArray.count ? filteredArray : nil;
}


@end
