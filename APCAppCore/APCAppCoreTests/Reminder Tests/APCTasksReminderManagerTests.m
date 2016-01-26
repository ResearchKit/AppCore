//
//  APCTasksReminderManagerTests.m
//  APCAppCore
//
//  Created by Michael L DePhillips on 1/26/16.
//  Copyright © 2016 Apple, Inc. All rights reserved.
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
@end

@implementation APCTasksReminderManagerTests

/** Put setup code here. This method is called before the invocation of each test method in the class. */
- (void) setUp
{
    [super setUp];
    
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
    XCTAssertEqual(nextSundayAt5PM, sundayAt5Pm.fireDate);
    
    NSDate* nextTuesdayAt5PM = [NSDate dateWithISO8601String:@"2016-01-26T22:00:00+00:00"];
    XCTAssertEqual(nextTuesdayAt5PM, tuesdayAt5Pm.fireDate);
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
    XCTAssertEqual(nextSundayAt5PM, sundayAt5Pm.fireDate);
    
    NSDate* nextTuesdayAt5PM = [NSDate dateWithISO8601String:@"2016-01-26T22:00:00+00:00"];
    XCTAssertEqual(nextTuesdayAt5PM, tuesdayAt5Pm.fireDate);
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
    XCTAssertEqual(nextSundayAt5PM, sundayAt5Pm.fireDate);
    
    NSDate* nextTuesdayAt5PM = [NSDate dateWithISO8601String:@"2016-02-2T22:00:00+00:00"];
    XCTAssertEqual(nextTuesdayAt5PM, tuesdayAt5Pm.fireDate);
    
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
    XCTAssertEqual(nextSundayAt5PM, sundayAt5Pm.fireDate);
    
    NSDate* nextTuesdayAt5PM = [NSDate dateWithISO8601String:@"2016-02-2T22:00:00+00:00"];
    XCTAssertEqual(nextTuesdayAt5PM, tuesdayAt5Pm.fireDate);
    
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

- (void) testMPowerDaily
{
    // Saturday
    self.reminderManager.mockNow = [NSDate dateWithISO8601String:@"2016-01-23T10:00:00+00:00"];
    
    self.reminderManager.daysOfTheWeekToRepeat = @[@(kAPCTaskReminderDayOfWeekEveryDay)];
    
    [self.reminderManager updateTasksReminder];
    
    XCTAssertEqual(1, self.reminderManager.scheduledLocalNotification.count);
    
    UILocalNotification* saturdayAt5Pm = self.reminderManager.scheduledLocalNotification[0];
    
    NSDate* thisSaturdayAt5PM = [NSDate dateWithISO8601String:@"2016-01-23T22:00:00+00:00"];
    XCTAssertEqual(thisSaturdayAt5PM, saturdayAt5Pm.fireDate);
    
    XCTAssertEqual(NSCalendarUnitDay, saturdayAt5Pm.repeatInterval);
}

@end
