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
#import "APCResult+AddOn.h"

#import "APCConstants.h"
#import "APCLog.h"
#import "NSDate+Helper.h"
#import "NSDictionary+APCAdditions.h"
#import "NSManagedObject+APCHelper.h"
#import "APCTask.h"
#import "APCTaskGroup.h"
#import "APCLocalization.h"

#import <UIKit/UIKit.h>

NSString * const kTaskReminderUserInfo = @"CurrentTaskReminder";
NSString * const kSubtaskReminderUserInfo = @"CurrentSubtaskReminder";
NSString * const kTaskReminderUserInfoKey = @"TaskReminderUserInfoKey";
NSString * const kSubtaskReminderUserInfoKey = @"SubtaskReminderUserInfoKey";
NSString * const kTaskReminderDayUserInfoKey = @"TaskReminderDayUserInfoKey";

static NSInteger kSecondsPerMinute = 60;
static NSInteger kMinutesPerHour = 60;
static NSInteger kSubtaskReminderDelayMinutes = 120;

NSString * gTaskReminderMessage;
NSString * gTaskReminderDelayMessage;

@interface APCTasksReminderManager ()
@property (strong, nonatomic) NSArray *taskGroups;
@property (strong, nonatomic) NSMutableDictionary *remindersToSend;
@property (strong, nonatomic) id <NSObject> localeChangeNotification;

@end

@implementation APCTasksReminderManager

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self setReminderMessage:NSLocalizedStringWithDefaultValue(@"Please complete your %@ activities today. Thank you for participating in the %@ study! %@", @"APCAppCore", APCBundle(), @"Please complete your %@ activities today. Thank you for participating in the %@ study! %@", @"Text for daily reminder to complete activities, to be filled in with the name of the study, the name of the study again, and the concatenation of the bodies of the individual reminders of activities yet to complete.")
                 andDelayMessage:NSLocalizedStringWithDefaultValue(@"Remind me in 1 hour", @"APCAppCore", APCBundle(), @"Remind me in 1 hour", @"\"Snooze\" prompt for reminder notification")];
        
        //posted by APCSettingsViewController on turning reminders on/off
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTasksReminder) name:APCUpdateTasksReminderNotification object:nil];
        //posted by APCBaseTaskViewController when user completes an activity
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTasksReminder) name:APCActivityCompletionNotification object:nil];
        
        self.reminders = [NSMutableArray new];
        self.remindersToSend = [NSMutableDictionary new];
        
        self.daysOfTheWeekToRepeat = @[@(kAPCTaskReminderDayOfWeekEveryDay)];
        
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
    [self cancelLocalNotificationsIfExist];
    
    if (self.reminderOn)
    {
        if ([self isDailyRepeating])
        {
            [self createDailyTaskReminder];
        }
        else
        {
            [self createWeeklyTaskReminders];
        }
    }
}

- (BOOL) isDailyRepeating {
    return self.daysOfTheWeekToRepeat.count == 1 &&
           [self.daysOfTheWeekToRepeat[0] unsignedIntegerValue] == kAPCTaskReminderDayOfWeekEveryDay;
}

- (NSArray *) existingLocalNotifications {
    UIApplication *app = [UIApplication sharedApplication];
    
    // This line has inconsistant behavior see
    // http://stackoverflow.com/questions/25948037/ios-8-uiapplication-sharedapplication-scheduledlocalnotifications-empty
    NSArray *eventArray = [app scheduledLocalNotifications];
    
    NSMutableArray *appNotifications = [NSMutableArray new];
    
    for (UILocalNotification *notification in eventArray) {
        NSDictionary *userInfoCurrent = notification.userInfo;
        if ([userInfoCurrent[kTaskReminderUserInfoKey] isEqualToString:kTaskReminderUserInfo] ||
            [userInfoCurrent[kSubtaskReminderUserInfoKey] isEqualToString:kSubtaskReminderUserInfo])
        {
            [appNotifications addObject:notification];
        }
    }

    return appNotifications;
}

- (void) cancelLocalNotificationsIfExist
{
    UIApplication *app = [UIApplication sharedApplication];
    
    // In my experience, the "existingLocalNotifications" method called below had inconsistant behavior
    // To mitigate the inconsistancy, you can simply remove all local notifications from this app
    // See http://stackoverflow.com/questions/25948037/ios-8-uiapplication-sharedapplication-scheduledlocalnotifications-empty
    
    if (self.updatingRemindersRemovesAllLocalNotifications)
    {
        [app cancelAllLocalNotifications];
        return;
    }
    
    NSArray *notifications = [self existingLocalNotifications];
    
    for (UILocalNotification * notification in notifications) {
        [app cancelLocalNotification:notification];
        APCLogDebug(@"Cancelled Notification: %@", notification);
        
    }
}

- (void) createDailyTaskReminder
{
    [self createTaskReminderWithRepeatInterval:NSCalendarUnitDay
                                   withWeekday:kAPCTaskReminderDayOfWeekEveryDay];
}

- (void) createWeeklyTaskReminders
{
    for (NSNumber* dayOfWeekNumber in self.daysOfTheWeekToRepeat)
    {
        NSUInteger dayOfWeekInt = [dayOfWeekNumber unsignedIntegerValue];
        [self createTaskReminderWithRepeatInterval:NSCalendarUnitWeekOfYear
                                       withWeekday:dayOfWeekInt];
    }
}

- (void) setReminderMessage:(NSString*)reminderMessage
            andDelayMessage:(NSString*)delayMessage
{
    if (_localeChangeNotification)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:_localeChangeNotification
                                                        name:NSCurrentLocaleDidChangeNotification
                                                      object:nil];
    }
    
    void (^localizeBlock)() = [^{
        gTaskReminderMessage = reminderMessage;
        gTaskReminderDelayMessage = delayMessage;
    } copy];
    
    _localeChangeNotification = [[NSNotificationCenter defaultCenter]
                                 addObserverForName:NSCurrentLocaleDidChangeNotification
                                 object:nil
                                 queue:nil
                                 usingBlock:^(NSNotification * _Nonnull __unused note)
                                 {
                                     localizeBlock();
                                 }];
    
    // Set the messages
    localizeBlock();
}

- (void) createTaskReminderWithRepeatInterval:(NSCalendarUnit)repeatInterval
                                  withWeekday:(NSUInteger)weekdayIfRepeatIsWeekly
{
    // Schedule the Task notification
    UILocalNotification* taskNotification = [[UILocalNotification alloc] init];
    taskNotification.alertBody = [self reminderMessage];
    
    BOOL subtaskReminderOnly = NO;
    
    // After the reminder message has been formed, we can correctly calculate the fire dates
    NSDate* subtaskFireDate = [self calculateDailySubtaskReminderFireDate];
    NSDate* normalFireDate = [self calculateDailyTaskReminderFireDate];
    
    if (repeatInterval == NSCalendarUnitWeekOfYear)
    {
        subtaskFireDate = [self calculateWeeklySubtaskReminderFireDateFromWeekday:weekdayIfRepeatIsWeekly];
        normalFireDate = [self calculateWeeklyTaskReminderFireDateFromWeekday:weekdayIfRepeatIsWeekly];
    }
    
    // If we are repeating per weekday, still schedule notifications for next week if we have already completed this week's
    // This will ensure that it gets shown for next week if the user doesnt enter the app again until then
    if (self.remindersToSend.count > 0 || repeatInterval  == NSCalendarUnitWeekOfYear) {
        
        if (self.remindersToSend.count == 1 && [self shouldSendSubtaskReminder]) {
            subtaskReminderOnly = YES;
        }
        
        taskNotification.fireDate = subtaskReminderOnly ? subtaskFireDate : normalFireDate;
        taskNotification.repeatInterval = repeatInterval;
        
        taskNotification.timeZone = [NSTimeZone localTimeZone];
        taskNotification.soundName = UILocalNotificationDefaultSoundName;
        
        NSMutableDictionary *notificationInfo = [[NSMutableDictionary alloc] init];
        notificationInfo[kTaskReminderUserInfoKey] = kTaskReminderUserInfo; // Task Reminder
        
        // This line makes weekly notifications unique
        notificationInfo[kTaskReminderDayUserInfoKey] = @(weekdayIfRepeatIsWeekly);
        
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
    
    // Create a subtask reminder if needed
    if ([self shouldSendSubtaskReminder] && !subtaskReminderOnly) {
        [self createSubtaskReminderWithRepeatInterval:repeatInterval
                                          andFireDate:subtaskFireDate];
    }
}

- (void) createSubtaskReminderWithRepeatInterval:(NSCalendarUnit)repeatInterval
                                     andFireDate:(NSDate*)fireDate
{
    // Schedule the Subtask notification
    UILocalNotification* subtaskReminder = [[UILocalNotification alloc] init];
    
    subtaskReminder.alertBody = [self subtaskReminderMessage]; //include only the subtask reminder body
    subtaskReminder.fireDate = fireDate;  //delay by subtask reminder delay
    subtaskReminder.timeZone = [NSTimeZone localTimeZone];
    subtaskReminder.repeatInterval = repeatInterval;
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
    delayReminderAction.title = gTaskReminderDelayMessage;
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
-(NSString *)reminderMessage {
    
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
    
    return [NSString stringWithFormat:gTaskReminderMessage, [self studyName], [self studyName], reminders];
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
    
    return [NSString stringWithFormat:gTaskReminderMessage, [self studyName], [self studyName], reminders];
}

- (NSString *)studyName {
    NSString *filePath = [[APCAppDelegate sharedAppDelegate] pathForResource:@"StudyOverview" ofType:@"json"];
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

- (NSDate*) calculateDailyTaskReminderFireDate
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

- (NSDate*) calculateDailySubtaskReminderFireDate
{
    NSTimeInterval reminderOffset = ([[APCTasksReminderManager reminderTimesArray] indexOfObject:self.reminderTime]) * kMinutesPerHour * kSecondsPerMinute;
    //add subtask reminder delay
    reminderOffset += kSubtaskReminderDelayMinutes * kSecondsPerMinute;
    
    return [[NSDate todayAtMidnight] dateByAddingTimeInterval:reminderOffset];
}

- (NSDate*) calculateWeeklyTaskReminderFireDateFromWeekday:(NSUInteger)dayOfTheWeekInt
{
    NSTimeInterval reminderOffset = ([[APCTasksReminderManager reminderTimesArray] indexOfObject:self.reminderTime]) * kMinutesPerHour * kSecondsPerMinute;
    
    NSDate *now = [NSDate new];
    NSDate *dateToSet = [NSDate priorSundayAtMidnightFromDate:now];
    
    // If we completed all the tasks for this week, we will remind them again starting next week
    if (self.remindersToSend.count == 0)
    {
        dateToSet = [NSDate nextSundayAtMidnightFromDate:now];
    }
    
    dateToSet = [dateToSet dateByAddingDays:(dayOfTheWeekInt - kAPCTaskReminderDayOfWeekSunday)];
    
    // Make sure the date is in the future, otherwise the local notification wont trigger
    while (([dateToSet timeIntervalSince1970] + reminderOffset) < [now timeIntervalSince1970])
    {
        // this removes hours component, so add that back in when we return the date in the method
        dateToSet = [dateToSet dateByAddingDays:kDateHelperDaysInAWeek];
    }
    
    return [dateToSet dateByAddingTimeInterval:reminderOffset];
}

- (NSDate*) calculateWeeklySubtaskReminderFireDateFromWeekday:(NSUInteger)dayOfTheWeekInt
{
    // For weekly, the sub-task reminder is the same as the normal reminder, so just return that
    return [self calculateWeeklyTaskReminderFireDateFromWeekday:dayOfTheWeekInt];
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

/**
 * This method will make sure if the user adds kAPCTaskReminderDayOfWeekEveryDay, it will limit it to only item in the array
 */
- (void)setDaysOfTheWeekToRepeat:(NSArray *)daysOfTheWeekToRepeat
{
    BOOL containsEveryDayOfWeek = NO;
    for (NSNumber* dayOfTheWeek in daysOfTheWeekToRepeat)
    {
        if ([dayOfTheWeek unsignedIntegerValue] == kAPCTaskReminderDayOfWeekEveryDay)
        {
            containsEveryDayOfWeek = YES;
        }
    }
    
    if (containsEveryDayOfWeek)
    {
        _daysOfTheWeekToRepeat = @[@(kAPCTaskReminderDayOfWeekEveryDay)];
    }
    else
    {
        _daysOfTheWeekToRepeat = daysOfTheWeekToRepeat;
    }
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
    } else if (!groupForTaskID.isFullyCompleted ) {//if this task has not been completed but was required, include it in the reminder
        includeTask = YES;
    }
    
    return includeTask;
}

@end
