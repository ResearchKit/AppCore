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
#import "APCAppDelegate.h"
#import "APCScheduledTask+AddOn.h"
#import "APCResult+AddOn.h"

#import "APCConstants.h"
#import "APCLog.h"
#import "NSDate+Helper.h"
#import "NSDictionary+APCAdditions.h"
#import "NSManagedObject+APCHelper.h"
#import "APCTask.h"
#import "APCTaskGroup.h"

#import <UIKit/UIKit.h>


NSString * const kTaskReminderUserInfo = @"CurrentTaskReminder";
NSString * const kSubtaskReminderUserInfo = @"CurrentSubtaskReminder";
NSString * const kTaskReminderUserInfoKey = @"TaskReminderUserInfoKey";
NSString * const kSubtaskReminderUserInfoKey = @"SubtaskReminderUserInfoKey";

static NSInteger kSecondsPerMinute = 60;
static NSInteger kMinutesPerHour = 60;
static NSInteger kSubtaskReminderDelayMinutes = 120;

NSString * const kTaskReminderMessage = @"Please complete your %@ activities today. Thank you for participating in the %@ study! %@";
NSString * const kTaskReminderDelayMessage = @"Remind me in 1 hour";

@interface APCTasksReminderManager ()
@property (strong, nonatomic) NSArray *taskGroups;
@property (strong, nonatomic) NSMutableDictionary *remindersToSend;
@end

@implementation APCTasksReminderManager

- (instancetype)init {
    self = [super init];
    if (self) {
        //posted by APCSettingsViewController on turning reminders on/off
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTasksReminder) name:APCUpdateTasksReminderNotification object:nil];
        //posted by APCBaseTaskViewController when user completes an activity
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTasksReminder) name:APCActivityCompletionNotification object:nil];
        
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

//updated in parallel with ActivitiesViewController
-(void)handleActivitiesUpdateWithTodaysTaskGroups: (NSArray *) todaysTaskGroups {
    self.taskGroups = todaysTaskGroups;
    [self updateTasksReminder];
}

- (void) updateTasksReminder
{
    
    if (self.reminderOn) {
        [self createTaskReminder];
    }
    else {
        [self cancelLocalNotificationsIfExist];
    }
    
}

- (NSArray *) existingLocalNotifications {
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *eventArray = [app scheduledLocalNotifications];
    NSMutableArray *appNotifications = [NSMutableArray new];
    
    for (UILocalNotification *notification in eventArray) {
        NSDictionary *userInfoCurrent = notification.userInfo;
        if ([userInfoCurrent[kTaskReminderUserInfoKey] isEqualToString:kTaskReminderUserInfo] ||
            [userInfoCurrent[kSubtaskReminderUserInfoKey] isEqualToString:kSubtaskReminderUserInfo]) {
            [appNotifications addObject:notification];
        }
    }

    return appNotifications;
    
}

- (void) cancelLocalNotificationsIfExist {
    NSArray *notifications = [self existingLocalNotifications];
    UIApplication *app = [UIApplication sharedApplication];
    
    for (UILocalNotification * notification in notifications) {
        [app cancelLocalNotification:notification];
        APCLogDebug(@"Cancelled Notification: %@", notification);
        
    }
}

- (void) createTaskReminder {
    
    [self cancelLocalNotificationsIfExist];
    
    // Schedule the Task notification
    UILocalNotification* taskNotification = [[UILocalNotification alloc] init];
    taskNotification.alertBody = [self reminderMessage];

    BOOL subtaskReminderOnly = NO;
    if (self.remindersToSend.count >0) {
        
        if (self.remindersToSend.count == 1 && [self shouldSendSubtaskReminder]) {
            subtaskReminderOnly = YES;
        }
        
        taskNotification.fireDate = subtaskReminderOnly ? [self calculateSubtaskReminderFireDate] : [self calculateTaskReminderFireDate];
        taskNotification.timeZone = [NSTimeZone localTimeZone];
        taskNotification.repeatInterval = NSCalendarUnitDay;
        taskNotification.soundName = UILocalNotificationDefaultSoundName;
        
        NSMutableDictionary *notificationInfo = [[NSMutableDictionary alloc] init];
        notificationInfo[kTaskReminderUserInfoKey] = kTaskReminderUserInfo;//Task Reminder
        taskNotification.userInfo = notificationInfo;
        taskNotification.category = kTaskReminderDelayCategory;
        
        //migration if notifications were registered without a category.
        if ([[UIApplication sharedApplication] currentUserNotificationSettings].categories.count == 0 &&
            [[UIApplication sharedApplication] currentUserNotificationSettings].types == (UIUserNotificationTypeAlert
                                                                                          |UIUserNotificationTypeBadge
                                                                                          |UIUserNotificationTypeSound))
        {
            UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeAlert
                                                                                                 |UIUserNotificationTypeBadge
                                                                                                 |UIUserNotificationTypeSound)
                                                                                     categories:[APCTasksReminderManager taskReminderCategories]];
            
            [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
            [[NSUserDefaults standardUserDefaults]synchronize];
        }
        
        [[UIApplication sharedApplication] scheduleLocalNotification:taskNotification];
        
        APCLogEventWithData(kSchedulerEvent, (@{@"event_detail":[NSString stringWithFormat:@"Scheduled Reminder: %@. Body: %@", taskNotification, taskNotification.alertBody]}));
    }
    
    //create a subtask reminder if needed
    if ([self shouldSendSubtaskReminder] && !subtaskReminderOnly) {
        [self createSubtaskReminder];
    }
    
}

- (void) createSubtaskReminder {
    
    // Schedule the Subtask notification
    UILocalNotification* subtaskReminder = [[UILocalNotification alloc] init];
    
    subtaskReminder.alertBody = [self subtaskReminderMessage];//include only the subtask reminder body
    subtaskReminder.fireDate = [self calculateSubtaskReminderFireDate];//delay by subtask reminder delay
    subtaskReminder.timeZone = [NSTimeZone localTimeZone];
    subtaskReminder.repeatInterval = NSCalendarUnitDay;
    subtaskReminder.soundName = UILocalNotificationDefaultSoundName;
    
    NSMutableDictionary *notificationInfo = [[NSMutableDictionary alloc] init];
    notificationInfo[kSubtaskReminderUserInfoKey] = kSubtaskReminderUserInfo;//Subtask Reminder
    subtaskReminder.userInfo = notificationInfo;
    subtaskReminder.category = kTaskReminderDelayCategory;
    
    if (self.remindersToSend.count >0) {
        
        [[UIApplication sharedApplication] scheduleLocalNotification:subtaskReminder];
        
        APCLogEventWithData(kSchedulerEvent, (@{@"event_detail":[NSString stringWithFormat:@"Scheduled Subtask Reminder: %@. Body: %@", subtaskReminder, subtaskReminder.alertBody]}));
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
    
    return [NSString stringWithFormat:kTaskReminderMessage, [self studyName], [self studyName], reminders];
}

-(NSString *)subtaskReminderMessage{
    
    NSString *reminders = @"\n";
    //concatenate body of each message with \n
    
    for (APCTaskReminder *taskReminder in self.reminders) {
        if ([self includeTaskInReminder:taskReminder] && taskReminder.resultsSummaryKey) {
            reminders = [reminders stringByAppendingString:@"• "];
            reminders = [reminders stringByAppendingString:taskReminder.reminderBody];
            reminders = [reminders stringByAppendingString:@"\n"];
            self.remindersToSend[taskReminder.reminderIdentifier] = taskReminder;
        }
    }
    
    return [NSString stringWithFormat:kTaskReminderMessage, [self studyName], [self studyName], reminders];;
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
    NSNumber * flag = [[NSUserDefaults standardUserDefaults] objectForKey:kTasksReminderDefaultsOnOffKey];
    //Setting up defaults using initialization options
    if (flag == nil) {
        //default to on if user has given Notification permissions
        if ([[UIApplication sharedApplication] currentUserNotificationSettings].types != UIUserNotificationTypeNone){
            flag = @YES;
            [[NSUserDefaults standardUserDefaults] setObject:flag forKey:kTasksReminderDefaultsOnOffKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    
    //if Notifications are not enabled, set Reminders to off
    if ([[UIApplication sharedApplication] currentUserNotificationSettings].types == UIUserNotificationTypeNone) {
        flag = @NO;
        [[NSUserDefaults standardUserDefaults] setObject:flag forKey:kTasksReminderDefaultsOnOffKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    return [flag boolValue];
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

- (NSDate*) calculateTaskReminderFireDate
{
    NSTimeInterval reminderOffset = ([[APCTasksReminderManager reminderTimesArray] indexOfObject:self.reminderTime]) * kMinutesPerHour * kSecondsPerMinute;
    
    NSDate *dateToSet = [NSDate new];
    if (self.remindersToSend.count == 0) {
        dateToSet = [[NSDate tomorrowAtMidnight] dateByAddingTimeInterval:reminderOffset];
    }else{
        dateToSet = [[NSDate todayAtMidnight] dateByAddingTimeInterval:reminderOffset];
    }
    
    return dateToSet;
}

- (NSDate*) calculateSubtaskReminderFireDate
{
    NSTimeInterval reminderOffset = ([[APCTasksReminderManager reminderTimesArray] indexOfObject:self.reminderTime]) * kMinutesPerHour * kSecondsPerMinute;
    //add subtask reminder delay
    reminderOffset += kSubtaskReminderDelayMinutes * kSecondsPerMinute;
    
    return [[NSDate todayAtMidnight] dateByAddingTimeInterval:reminderOffset];
}

- (BOOL) shouldSendSubtaskReminder{
    
    BOOL shouldSend = NO;
    
    //Send the subtask reminder if self.remindersToSend contains a reminder where taskReminder.resultsSummaryKey != nil
    for (NSString *key in self.remindersToSend) {
        
        APCTaskReminder *reminder = [self.remindersToSend objectForKey:key];
        if (reminder) {
            if (reminder.resultsSummaryKey) {
                shouldSend = YES;
            }
        }
    }
    
    return shouldSend;
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
    
    APCTaskGroup *groupForTaskID;
    for (APCTaskGroup *group in self.taskGroups) {
        
        if ([group.task.taskID isEqualToString:taskReminder.taskID]) {
            groupForTaskID = group;
            break;
        }
    }
    
    if (!groupForTaskID) {
        includeTask = NO;
    }else if (!groupForTaskID.isFullyCompleted ) {//if this task has not been completed but was required, include it in the reminder
        includeTask = YES;
    }else if (taskReminder.resultsSummaryKey != nil) {
        //we have a completed task with a subtask reminder. Get the results object from task.
        NSArray *allCompletedActivitiesForTaskID = [groupForTaskID.requiredCompletedTasks arrayByAddingObjectsFromArray:groupForTaskID.gratuitousCompletedTasks];
        
        for (APCScheduledTask *subtask in allCompletedActivitiesForTaskID) {
            if (subtask.results.count > 0) {
                includeTask = NO;
                NSString * resultSummary = subtask.lastResult.resultSummary;
                
                NSDictionary * dictionary = resultSummary ? [NSDictionary dictionaryWithJSONString:resultSummary] : nil;
                
                NSString *result;
                if (dictionary.count > 0) {
                    result = [dictionary objectForKey:taskReminder.resultsSummaryKey];
                }
                
                NSArray *results = [[NSArray alloc]initWithObjects:result, nil];
                NSArray *completedSubtask = [results filteredArrayUsingPredicate:taskReminder.completedTaskPredicate];
                if (completedSubtask.count == 0){
                    includeTask = YES;
                }
            }
        }
    }
    
    return includeTask;
}

@end
