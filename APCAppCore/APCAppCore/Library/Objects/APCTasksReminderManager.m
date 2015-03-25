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

NSString * const kTaskReminderUserInfo = @"CurrentTaskReminder";
NSString * const kTaskReminderUserInfoKey = @"TaskReminderUserInfoKey";
static NSInteger kSecondsPerMinute = 60;
static NSInteger kMinutesPerHour = 60;

NSString * const kTaskReminderMessage = @"Please complete your %@ activities today. Thank you for participating in the %@ study!";

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
    localNotification.alertBody = [NSString stringWithFormat:[self reminderMessage], [self studyName], [self studyName]];
    localNotification.repeatInterval = NSCalendarUnitDay;
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    
    NSMutableDictionary *notificationInfo = [[NSMutableDictionary alloc] init];
    notificationInfo[kTaskReminderUserInfoKey] = kTaskReminderUserInfo;
    localNotification.userInfo = notificationInfo;
    
    //Check if the notifications are registrered.
    //Your app is added to the Settings app as soon as you call registerUserNotificationSettings
    // Thus this has to be called to "install" the app into the settings, once it's called the user can turn it off and on
    if ([[UIApplication sharedApplication] currentUserNotificationSettings].types == UIUserNotificationTypeNone) {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeAlert
                                                                                             |UIUserNotificationTypeBadge
                                                                                             |UIUserNotificationTypeSound) categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    APCLogEventWithData(kSchedulerEvent, (@{@"event_detail":[NSString stringWithFormat:@"Scheduled Reminder: %@", localNotification]}));
}

-(NSString *)reminderMessage{
    
    return kTaskReminderMessage;
}

- (NSDate*) calculateFireDate
{
    NSTimeInterval reminderOffset = ([[APCTasksReminderManager reminderTimesArray] indexOfObject:self.reminderTime]) * kMinutesPerHour * kSecondsPerMinute;
    APCAppDelegate * delegate = (APCAppDelegate*)[UIApplication sharedApplication].delegate;
    NSDate *dateToSet = (delegate.dataSubstrate.countOfCompletedScheduledTasksForToday == delegate.dataSubstrate.countOfAllScheduledTasksForToday) ? [[NSDate tomorrowAtMidnight] dateByAddingTimeInterval:reminderOffset] : [[NSDate todayAtMidnight] dateByAddingTimeInterval:reminderOffset];
    return dateToSet;
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



@end
