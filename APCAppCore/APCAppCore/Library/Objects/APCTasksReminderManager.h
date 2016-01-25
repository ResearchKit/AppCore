// 
//  APCTasksReminderManager.h 
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
 
#import <Foundation/Foundation.h>
#import "APCTaskReminder.h"

// These must be reflected by NSCalendar NSCalendarUnitWeekday, except for the EveryDay value
static NSUInteger const kAPCTaskReminderDayOfWeekEveryDay    = 0;
static NSUInteger const kAPCTaskReminderDayOfWeekSunday      = 1;
static NSUInteger const kAPCTaskReminderDayOfWeekMonday      = 2;
static NSUInteger const kAPCTaskReminderDayOfWeekTuesday     = 3;
static NSUInteger const kAPCTaskReminderDayOfWeekWednesday   = 4;
static NSUInteger const kAPCTaskReminderDayOfWeekThursday    = 5;
static NSUInteger const kAPCTaskReminderDayOfWeekFriday      = 6;
static NSUInteger const kAPCTaskReminderDayOfWeekSaturday    = 7;

@interface APCTasksReminderManager : NSObject
@property (nonatomic) BOOL reminderOn;
@property (nonatomic, strong) NSString * reminderTime; //Should be an element of reminderTimesArray
@property (strong, nonatomic, getter=reminders) NSMutableArray *reminders;

/**
 * The days of the week to repeat the reminder, defaults to include every day
 * Object in the array must be of type APCTaskReminderDayOfWeek
 */
@property (nonatomic, strong) NSArray* daysOfTheWeekToRepeat;

/*
 * If true, all local notifications in this app (even ones that are not reminders) will be removed
 * If false, the app will try and find only reminder notifications to delete; however this has inconsistant behavior
 */
@property (nonatomic) BOOL updatingRemindersRemovesAllLocalNotifications;

/*
 * Update reminder messaging
 * This defualts to...
 * "Please complete your StudyName activities today. Thank you for participating in the StudyName study!"
 */
- (void) setReminderMessage:(NSString*)reminderMessage
            andDelayMessage:(NSString*)delayMessage;

- (void) updateTasksReminder;
- (void)manageTaskReminder:(APCTaskReminder *)reminder;
+ (NSArray*) reminderTimesArray;
+ (NSSet *) taskReminderCategories;

- (void)handleActivitiesUpdateWithTodaysTaskGroups:(NSArray *) todaysTaskGroups;
@end
