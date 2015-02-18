//
//  APCMedicationStorageTests.m
//  AppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "APCMedicationDataStorageEngine.h"
#import "APCMedicationWeeklySchedule.h"
#import "APCMedicationLozenge.h"
#import "APCMedTrackerMedicationSchedule+Helper.h"
#import "APCAppDelegate.h"


@interface APCMedicationStorageTests : XCTestCase

@end


@implementation APCMedicationStorageTests

- (void) setUp
{
    [super setUp];

    [APCMedicationDataStorageEngine startup];

//    [[[UIApplication sharedApplication] delegate] application: nil willFinishLaunchingWithOptions: nil];
//
//    [UIApplication m]
}

- (void) tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void) testWithCoreDataStuff
{
    NSArray *daysOfTheWeek = @[ @(1), @(5) ];
    NSNumber *timesPerDay = @(3);
    NSOperationQueue *someQueue = [NSOperationQueue new];
    someQueue.name = @"Waiting for 'create' op to finish...";

    [APCMedTrackerMedicationSchedule newScheduleWithMedication: nil
                                                        dosage: nil
                                                         color: nil
                                                 daysOfTheWeek: daysOfTheWeek
                                           numberOfTimesPerDay: timesPerDay
                                               andUseThisQueue: someQueue
                                              toDoThisWhenDone: ^(id createdObject, NSTimeInterval operationDuration) {

                                                  APCMedTrackerMedicationSchedule *schedule = createdObject;
                                                  NSLog (@"Created a schedule!  Creation time = %f seconds.  Schedule = %@" , operationDuration, schedule);

                                              }];

    NSLog (@"Waiting for schedule-generator to finish...");
    [NSThread sleepForTimeInterval: 60];
    NSLog (@"Done waiting.  Hopefully exiting the app.");
}

- (void) testCreateWeeklySchedule
{
    NSArray *medications = [APCMedicationDataStorageEngine allMedications];
    NSArray *colors = [APCMedicationDataStorageEngine allColors];
    NSArray *dosages = [APCMedicationDataStorageEngine allDosages];
    NSArray *sampleSchedules = [APCMedicationDataStorageEngine allSampleSchedules];
    NSArray *sampleDosesTaken = [APCMedicationDataStorageEngine allSampleDosesTaken];


    NSLog (@"The medications on disk are: %@", medications);
    NSLog (@"The colors on disk are: %@", colors);
    NSLog (@"The dosages on disk are: %@", dosages);
    NSLog (@"The sample schedules on disk are: %@", sampleSchedules);
    NSLog (@"The sample doses on disk are: %@", sampleDosesTaken);

    NSArray *daysOfTheWeek = @[ @(1), @(5) ];
    NSNumber *timesPerDay = @(3);

    APCMedicationWeeklySchedule *schedule = [APCMedicationWeeklySchedule weeklyScheduleWithMedication: medications [0]
                                                                                               dosage: dosages [0]
                                                                                                color: colors [1]
                                                                                        daysOfTheWeek: daysOfTheWeek
                                                                                  numberOfTimesPerDay: timesPerDay];

    NSLog (@"For a new schedule:");
    NSLog (@"- Medication name: %@", schedule.medicationName);
    NSLog (@"- Schedule color: %@", schedule.color);
    NSLog (@"- Frequencies and Days: %@", schedule.frequenciesAndDays);
    NSLog (@"- Dosage value: %@", schedule.dosageValue);
    NSLog (@"- Dosage Text: %@", schedule.dosageText);

    [schedule save];

    NSArray *lozenges = schedule.blankLozenges;
    NSLog (@"The blank lozenges are:  %@", lozenges);

    APCMedicationLozenge *lozenge = lozenges [0];
    [lozenge takeDoseNowAndSave];
    NSLog (@"After taking one dose, the first lozenge is:  %@", lozenge);

    NSLog (@"Waiting 3 seconds so the 'save' has a chance to finish...");
    [NSThread sleepForTimeInterval: 3];
    NSLog (@"...done!");
}

@end






















