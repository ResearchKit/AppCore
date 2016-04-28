//
//  APCTasksReminderManagerTests.m
//  APCAppCore
//
// Copyright (c) 2016, Sage Bionetworks. All rights reserved.
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

#import <XCTest/XCTest.h>
#import "MockAPCTasksReminderManager.h"

static NSString* const kWalkingTaskReminder = @"WalkingTaskReminder";
static NSString* const kCardiacTaskReminder = @"CardiacTaskReminder";
static NSString* const kBalanceTaskReminder = @"BalanceTaskReminder";

static NSString* const kWalkingName = @"Walking Assessment";
static NSString* const kCardiacName = @"Cardiac Health Activity";
static NSString* const kBalanceName = @"Balance Assessment";

@interface APCTasksReminderManagerTests : XCTestCase
@property (nonatomic, strong) MockAPCTasksReminderManager* reminderManager;
@property (nonatomic, strong) NSTimeZone* originalTimeZone;
@end

@implementation APCTasksReminderManagerTests

/** Put setup code here. This method is called before the invocation of each test method in the class. */
- (void) setUp
{
    [super setUp];
    
    self.originalTimeZone = [NSTimeZone defaultTimeZone];
    [NSTimeZone setDefaultTimeZone:[NSTimeZone timeZoneWithName:@"America/New_York"]];
    
    self.reminderManager = [[MockAPCTasksReminderManager alloc] init];
    
    self.reminderManager.updatingRemindersRemovesAllLocalNotifications = YES;
    
    self.reminderManager.reminderTime = [APCTasksReminderManager reminderTimesArray][17]; // 17 = 5pm
    
    [self.reminderManager setReminderMessage:@"Reminder Message"
                             andDelayMessage:@"Delay Reminder 1 Hour"];
    
    [self.reminderManager handleActivitiesUpdateWithTodaysTaskGroups:@[]];
    
    APCTaskReminder *walkingAssessmentReminder = [[APCTaskReminder alloc] initWithTaskID:kWalkingTaskReminder reminderBody:kWalkingName];
    APCTaskReminder *cardiacHealthReminder = [[APCTaskReminder alloc] initWithTaskID:kCardiacTaskReminder reminderBody:kCardiacName];
    APCTaskReminder *balanceAssessmentReminder = [[APCTaskReminder alloc] initWithTaskID:kBalanceTaskReminder reminderBody:kBalanceName];
    
    [self.reminderManager setReminderKey:kWalkingTaskReminder toOn:YES];
    [self.reminderManager setReminderKey:kCardiacTaskReminder toOn:YES];
    [self.reminderManager setReminderKey:kBalanceTaskReminder toOn:YES];
    
    [self.reminderManager setAllReminders:YES];
    
    self.reminderManager.tasksFullComplete = @{
                                               kWalkingTaskReminder : @(NO),
                                               kCardiacTaskReminder : @(NO),
                                               kBalanceTaskReminder : @(NO)};
    
    [self.reminderManager.reminders removeAllObjects];
    [self.reminderManager manageTaskReminder:walkingAssessmentReminder];
    [self.reminderManager manageTaskReminder:cardiacHealthReminder];
    [self.reminderManager manageTaskReminder:balanceAssessmentReminder];
}

/** Put teardown code here. This method is called after the invocation of each test method in the class. */
- (void) tearDown
{
    [super tearDown];
    self.originalTimeZone = self.originalTimeZone;
}

- (void) testRemindersTurnedOff
{
    [self.reminderManager setAllReminders:NO];
    [self.reminderManager updateTasksReminder];
    XCTAssertEqual(0, self.reminderManager.scheduledLocalNotification.count);
}

- (void) testFphsSundayTuesdayNoneCompleteOnSaturday
{
    // Saturday
    self.reminderManager.mockNow = [NSDate dateWithISO8601String:@"2016-01-23T10:00:00+00:00"];
    
    self.reminderManager.daysOfTheWeekToRepeat = @[@(kAPCTaskReminderDayOfWeekSunday),
                                                   @(kAPCTaskReminderDayOfWeekTuesday)];
    
    [self.reminderManager updateTasksReminder];
    
    XCTAssertEqual(2, self.reminderManager.scheduledLocalNotification.count);
    
    UILocalNotification* sundayAt5Pm = self.reminderManager.scheduledLocalNotification[0];
    UILocalNotification* tuesdayAt5Pm = self.reminderManager.scheduledLocalNotification[1];
    
    NSDate* nextSundayAt5PM = [NSDate dateWithISO8601String:@"2016-01-24T22:00:00+00:00"];
    XCTAssertEqualObjects(nextSundayAt5PM, sundayAt5Pm.fireDate);
    
    NSDate* nextTuesdayAt5PM = [NSDate dateWithISO8601String:@"2016-01-26T22:00:00+00:00"];
    XCTAssertEqualObjects(nextTuesdayAt5PM, tuesdayAt5Pm.fireDate);
}

- (void) testFphsSundayTuesdayNoneCompleteOnTuesday
{
    // Saturday
    self.reminderManager.mockNow = [NSDate dateWithISO8601String:@"2016-01-26T10:00:00+00:00"];
    
    self.reminderManager.daysOfTheWeekToRepeat = @[@(kAPCTaskReminderDayOfWeekSunday),
                                                   @(kAPCTaskReminderDayOfWeekTuesday)];
    
    [self.reminderManager updateTasksReminder];
    
    XCTAssertEqual(2, self.reminderManager.scheduledLocalNotification.count);
    
    UILocalNotification* sundayAt5Pm = self.reminderManager.scheduledLocalNotification[0];
    UILocalNotification* tuesdayAt5Pm = self.reminderManager.scheduledLocalNotification[1];
    
    NSDate* nextSundayAt5PM = [NSDate dateWithISO8601String:@"2016-01-31T22:00:00+00:00"];
    XCTAssertEqualObjects(nextSundayAt5PM, sundayAt5Pm.fireDate);
    
    NSDate* nextTuesdayAt5PM = [NSDate dateWithISO8601String:@"2016-01-26T22:00:00+00:00"];
    XCTAssertEqualObjects(nextTuesdayAt5PM, tuesdayAt5Pm.fireDate);
}

- (void) testFphsSundayTuesdayAllCompleteOnSundayScheduleNextWeek
{
    // Sunday
    self.reminderManager.mockNow = [NSDate dateWithISO8601String:@"2016-01-24T10:00:00+00:00"];
    
    self.reminderManager.daysOfTheWeekToRepeat = @[@(kAPCTaskReminderDayOfWeekSunday),
                                                   @(kAPCTaskReminderDayOfWeekTuesday)];
    
    self.reminderManager.tasksFullComplete = @{
                                               kWalkingTaskReminder : @(YES),
                                               kCardiacTaskReminder : @(YES),
                                               kBalanceTaskReminder : @(YES)};
    
    [self.reminderManager updateTasksReminder];
    
    XCTAssertEqual(2, self.reminderManager.scheduledLocalNotification.count);
    
    UILocalNotification* sundayAt5Pm = self.reminderManager.scheduledLocalNotification[0];
    UILocalNotification* tuesdayAt5Pm = self.reminderManager.scheduledLocalNotification[1];
    
    NSDate* nextSundayAt5PM = [NSDate dateWithISO8601String:@"2016-01-31T22:00:00+00:00"];
    XCTAssertEqualObjects(nextSundayAt5PM, sundayAt5Pm.fireDate);
    
    NSDate* nextTuesdayAt5PM = [NSDate dateWithISO8601String:@"2016-02-2T22:00:00+00:00"];
    XCTAssertEqualObjects(nextTuesdayAt5PM, tuesdayAt5Pm.fireDate);
    
    XCTAssertEqual(NO, [sundayAt5Pm.alertBody containsString:kWalkingName]);
    XCTAssertEqual(NO,  [sundayAt5Pm.alertBody containsString:kCardiacName]);
    XCTAssertEqual(NO,  [sundayAt5Pm.alertBody containsString:kBalanceName]);
    
    XCTAssertEqual(NSCalendarUnitWeekOfYear, sundayAt5Pm.repeatInterval);
    XCTAssertEqual(NSCalendarUnitWeekOfYear, tuesdayAt5Pm.repeatInterval);
}

- (void) testFphsSundayTuesdayAllCompleteOnTuesdayScheduleNextWeek
{
    // Sunday
    self.reminderManager.mockNow = [NSDate dateWithISO8601String:@"2016-01-26T10:00:00+00:00"];
    
    self.reminderManager.daysOfTheWeekToRepeat = @[@(kAPCTaskReminderDayOfWeekSunday),
                                                   @(kAPCTaskReminderDayOfWeekTuesday)];
    
    self.reminderManager.tasksFullComplete = @{
                                               kWalkingTaskReminder : @(YES),
                                               kCardiacTaskReminder : @(YES),
                                               kBalanceTaskReminder : @(YES)};
    
    [self.reminderManager updateTasksReminder];
    
    XCTAssertEqual(2, self.reminderManager.scheduledLocalNotification.count);
    
    UILocalNotification* sundayAt5Pm = self.reminderManager.scheduledLocalNotification[0];
    UILocalNotification* tuesdayAt5Pm = self.reminderManager.scheduledLocalNotification[1];
    
    NSDate* nextSundayAt5PM = [NSDate dateWithISO8601String:@"2016-01-31T22:00:00+00:00"];
    XCTAssertEqualObjects(nextSundayAt5PM, sundayAt5Pm.fireDate);
    
    NSDate* nextTuesdayAt5PM = [NSDate dateWithISO8601String:@"2016-02-2T22:00:00+00:00"];
    XCTAssertEqualObjects(nextTuesdayAt5PM, tuesdayAt5Pm.fireDate);
    
    XCTAssertEqual(NO, [sundayAt5Pm.alertBody containsString:kWalkingName]);
    XCTAssertEqual(NO,  [sundayAt5Pm.alertBody containsString:kCardiacName]);
    XCTAssertEqual(NO,  [sundayAt5Pm.alertBody containsString:kBalanceName]);
    
    XCTAssertEqual(NSCalendarUnitWeekOfYear, sundayAt5Pm.repeatInterval);
    XCTAssertEqual(NSCalendarUnitWeekOfYear, tuesdayAt5Pm.repeatInterval);
}

- (void) testFphsSundayTuesdayAllTasksIncludedInAlert
{
    // Saturday
    self.reminderManager.mockNow = [NSDate dateWithISO8601String:@"2016-01-23T10:00:00+00:00"];
    
    [self.reminderManager updateTasksReminder];
    
    UILocalNotification* sundayAt5Pm = self.reminderManager.scheduledLocalNotification[0];
    
    XCTAssertEqual(YES, [sundayAt5Pm.alertBody containsString:kWalkingName]);
    XCTAssertEqual(YES, [sundayAt5Pm.alertBody containsString:kCardiacName]);
    XCTAssertEqual(YES, [sundayAt5Pm.alertBody containsString:kBalanceName]);
}

- (void) testFphsSundayTuesdayOneTaskIncludedInAlert
{
    // Saturday
    self.reminderManager.mockNow = [NSDate dateWithISO8601String:@"2016-01-23T10:00:00+00:00"];
    
    self.reminderManager.tasksFullComplete = @{
                                               kWalkingTaskReminder : @(NO),
                                               kCardiacTaskReminder : @(YES),
                                               kBalanceTaskReminder : @(YES)};
    
    [self.reminderManager updateTasksReminder];
    
    UILocalNotification* sundayAt5Pm = self.reminderManager.scheduledLocalNotification[0];
    
    XCTAssertEqual(YES, [sundayAt5Pm.alertBody containsString:kWalkingName]);
    XCTAssertEqual(NO,  [sundayAt5Pm.alertBody containsString:kCardiacName]);
    XCTAssertEqual(NO,  [sundayAt5Pm.alertBody containsString:kBalanceName]);
}

- (void) testTimeZoneChange
{
    NSTimeZone* oldTimeZone = [NSTimeZone defaultTimeZone];
    NSTimeZone* newTimeZone = [NSTimeZone timeZoneWithName:@"America/Denver"];
    [NSTimeZone setDefaultTimeZone:newTimeZone];
    self.reminderManager.mockTimeZone = newTimeZone;
    
    // Saturday
    self.reminderManager.mockNow = [NSDate dateWithISO8601String:@"2016-01-23T10:00:00+00:00"];
    
    self.reminderManager.daysOfTheWeekToRepeat = @[@(kAPCTaskReminderDayOfWeekSunday),
                                                   @(kAPCTaskReminderDayOfWeekTuesday)];
    
    [self.reminderManager updateTasksReminder];
    
    XCTAssertEqual(2, self.reminderManager.scheduledLocalNotification.count);
    
    UILocalNotification* sundayAt5Pm = self.reminderManager.scheduledLocalNotification[0];
    UILocalNotification* tuesdayAt5Pm = self.reminderManager.scheduledLocalNotification[1];
    
    NSDate* nextSundayAt5PM = [NSDate dateWithISO8601String:@"2016-01-25T00:00:00+00:00"];
    XCTAssertEqualObjects(nextSundayAt5PM, sundayAt5Pm.fireDate);
    
    NSDate* nextTuesdayAt5PM = [NSDate dateWithISO8601String:@"2016-01-27T00:00:00+00:00"];
    XCTAssertEqualObjects(nextTuesdayAt5PM, tuesdayAt5Pm.fireDate);
    
    [NSTimeZone setDefaultTimeZone:oldTimeZone];
    self.reminderManager.mockTimeZone = oldTimeZone;
}

- (void) testMPowerDaily
{
    // Saturday
    self.reminderManager.mockNow = [NSDate dateWithISO8601String:@"2016-01-23T10:00:00+00:00"];
    
    self.reminderManager.daysOfTheWeekToRepeat = @[@(kAPCTaskReminderDayOfWeekEveryDay)];
    
    [self.reminderManager updateTasksReminder];
    
    XCTAssertEqual(1, self.reminderManager.scheduledLocalNotification.count);
    
    UILocalNotification* saturdayAt5Pm = self.reminderManager.scheduledLocalNotification[0];
    
    NSDate* thisSaturdayAt5PM = [NSDate dateWithISO8601String:@"2016-01-23T22:00:00+00:00"];
    XCTAssertEqualObjects(thisSaturdayAt5PM, saturdayAt5Pm.fireDate);
    
    XCTAssertEqual(NSCalendarUnitDay, saturdayAt5Pm.repeatInterval);
}

@end
