//
//  APCMedicationStorageTests.m
//  AppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

//#import <UIKit/UIKit.h>
//#import <XCTest/XCTest.h>
//#import "APCMedicationDataStorageEngine.h"
//#import "APCMedicationWeeklySchedule.h"
//#import "APCMedicationLozenge.h"
//
//@interface APCMedicationStorageTests : XCTestCase
//
//@end
//
//@implementation APCMedicationStorageTests
//
//- (void) setUp
//{
//    [super setUp];
//
//    [APCMedicationDataStorageEngine startup];
//}
//
//- (void) tearDown
//{
//    // Put teardown code here. This method is called after the invocation of each test method in the class.
//    [super tearDown];
//}
//
//- (void) testCreateWeeklySchedule
//{
//    NSArray *medications = [APCMedicationDataStorageEngine allMedications];
//    NSArray *colors = [APCMedicationDataStorageEngine allColors];
//    NSArray *dosages = [APCMedicationDataStorageEngine allDosages];
//
//    NSArray *daysOfTheWeek = @[ @(1), @(5) ];
//    NSUInteger timesPerDay = 3;
//
//    APCMedicationWeeklySchedule *schedule = [APCMedicationWeeklySchedule weeklyScheduleWithMedication: medications [0]
//                                                                                               dosage: dosages [0]
//                                                                                                color: colors [1]
//                                                                                        daysOfTheWeek: daysOfTheWeek
//                                                                                  numberOfTimesPerDay: timesPerDay];
//
//    NSLog (@"For a new schedule:");
//    NSLog (@"- Medication name: %@", schedule.medicationName);
//    NSLog (@"- Schedule color: %@", schedule.color);
//    NSLog (@"- Frequencies and Days: %@", schedule.frequenciesAndDays);
//    NSLog (@"- Dosage value: %@", schedule.dosageValue);
//    NSLog (@"- Dosage Text: %@", schedule.dosageText);
//
//    [schedule save];
//
//    NSArray *lozenges = schedule.blankLozenges;
//    NSLog (@"The blank lozenges are:  %@", lozenges);
//
//    APCMedicationLozenge *lozenge = lozenges [0];
//    [lozenge takeDoseNowAndSave];
//    NSLog (@"After taking one dose, the first lozenge is:  %@", lozenge);
//}
//
//@end
//
//
//
//
//

















