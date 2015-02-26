//
//  APCTasksReminderManager.m
//  APCAppCore
//
//  Copyright (c) 2014 Apple Inc. All rights reserved.
//

#import "APCTasksReminderManager.h"
#import "APCAppCore.h"

NSString * const kTaskReminderUserInfo = @"CurrentTaskReminder";
NSString * const kTaskReminderUserInfoKey = @"TaskReminderUserInfoKey";
static NSInteger kSecondsPerMinute = 60;
static NSInteger kMinutesPerHour = 60;

NSString * const kTaskReminderMessage = @"Complete your activities for today!";

@interface APCTasksReminderManager ()

@end

@implementation APCTasksReminderManager

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTasksReminder) name:APCUpdateTasksReminderNotification object:nil];
        
        [self updateTasksReminder];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) updateTasksReminder
{
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
}

- (UILocalNotification*) existingLocalNotification {
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *eventArray = [app scheduledLocalNotifications];
    __block UILocalNotification * retValue;
    [eventArray enumerateObjectsUsingBlock:^(UILocalNotification * obj, NSUInteger __unused idx, BOOL * __unused stop) {
        NSDictionary *userInfoCurrent = obj.userInfo;
        if ([userInfoCurrent[kTaskReminderUserInfoKey] isEqualToString:kTaskReminderUserInfo]) {
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
    localNotification.alertBody = kTaskReminderMessage;
    localNotification.repeatInterval = NSCalendarUnitDay;
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    
    NSMutableDictionary *notificationInfo = [[NSMutableDictionary alloc] init];
    notificationInfo[kTaskReminderUserInfoKey] = kTaskReminderUserInfo;
    localNotification.userInfo = notificationInfo;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    APCLogEventWithData(kSchedulerEvent, (@{@"event_detail":[NSString stringWithFormat:@"Scheduled Reminder: %@", localNotification]}));
}

- (NSDate*) calculateFireDate
{
    NSTimeInterval reminderOffset = ([[APCTasksReminderManager reminderTimesArray] indexOfObject:self.reminderTime]) * kMinutesPerHour * kSecondsPerMinute;
    APCAppDelegate * delegate = (APCAppDelegate*)[UIApplication sharedApplication].delegate;
    NSDate *dateToSet = (delegate.dataSubstrate.countOfCompletedScheduledTasksForToday == delegate.dataSubstrate.countOfAllScheduledTasksForToday) ? [[NSDate tomorrowAtMidnight] dateByAddingTimeInterval:reminderOffset] : [[NSDate todayAtMidnight] dateByAddingTimeInterval:reminderOffset];
    return dateToSet;
}

/*********************************************************************************/
#pragma mark - Simulated Properties
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
        timeString = timeDefault?:@"5:00PM";
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

/*********************************************************************************/
#pragma mark - Helper
/*********************************************************************************/
+ (NSArray*) reminderTimesArray {
    static NSArray * timesArray = nil;
    if (timesArray == nil) {
        timesArray = @[
                       @"Midnight",
                       @"1:00AM",
                       @"2:00AM",
                       @"3:00AM",
                       @"4:00AM",
                       @"5:00AM",
                       @"6:00AM",
                       @"7:00AM",
                       @"8:00AM",
                       @"9:00AM",
                       @"10:00AM",
                       @"11:00AM",
                       @"Noon",
                       @"1:00PM",
                       @"2:00PM",
                       @"3:00PM",
                       @"4:00PM",
                       @"5:00PM",
                       @"6:00PM",
                       @"7:00PM",
                       @"8:00PM",
                       @"9:00PM",
                       @"10:00PM",
                       @"11:00PM"
                       ];
    }
    return timesArray;
}



@end
