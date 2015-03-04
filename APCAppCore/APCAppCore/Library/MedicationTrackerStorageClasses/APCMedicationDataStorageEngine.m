//
//  APCMedicationDataStorageEngine.m
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
//

#import "APCMedicationDataStorageEngine.h"
#import "APCMedicationActualMedicine.h"
#import "APCMedicationPossibleDosage.h"
#import "APCMedicationColor.h"
#import "APCMedicationDosageTaken.h"

static NSString * const FILE_FOR_PREDEFINED_COLORS = @"APCMedicationPredefinedColors.plist";
static NSString * const FILE_FOR_PREDEFINED_DOSAGES = @"APCMedicationPredefinedDosages.plist";
static NSString * const FILE_FOR_PREDEFINED_MEDICATIONS = @"APCMedicationPredefinedMedications.plist";
static NSString * const FILE_FOR_SAMPLE_DOSES_TAKEN = @"APCMedicationSampleDosesTaken.plist";
static NSString * const FILE_FOR_SAMPLE_SCHEDULES = @"APCMedicationSampleSchedules.plist";
static NSString * const FILE_FOR_REAL_SCHEDULES = @"SavedSchedules.plist";

static NSArray *possibleMedications = nil;
static NSArray *possibleDosages = nil;
static NSArray *possibleColors = nil;
static NSArray *sampleDosesTaken = nil;
static NSArray *sampleSchedules = nil;
static NSMutableArray *realSchedules = nil;

static NSOperationQueue *fileSaveQueue = nil;

@implementation APCMedicationDataStorageEngine

+ (void) startup
{
    fileSaveQueue = [NSOperationQueue new];
    fileSaveQueue.name = @"MedicationTracker file-save queue";

    realSchedules = [NSMutableArray new];

    possibleMedications = [APCMedicationActualMedicine inflatedItemsFromPlistFileWithName: FILE_FOR_PREDEFINED_MEDICATIONS];
    possibleDosages     = [APCMedicationPossibleDosage inflatedItemsFromPlistFileWithName: FILE_FOR_PREDEFINED_DOSAGES];
    possibleColors      = [APCMedicationColor          inflatedItemsFromPlistFileWithName: FILE_FOR_PREDEFINED_COLORS];
    sampleDosesTaken    = [APCMedicationDosageTaken    inflatedItemsFromPlistFileWithName: FILE_FOR_SAMPLE_DOSES_TAKEN];
    sampleSchedules     = [APCMedicationWeeklySchedule inflatedItemsFromPlistFileWithName: FILE_FOR_SAMPLE_SCHEDULES];

    // Not sure how to genericize this, yet.
    for (APCMedicationDosageTaken *dose in sampleDosesTaken)
    {
        dose.scheduleIAmBasedOn = [self objectWithId: dose.uniqueIdOfScheduleIAmBasedOn inList: sampleSchedules];
    }

    for (APCMedicationWeeklySchedule *schedule in sampleSchedules)
    {
        schedule.medication = [self objectWithId: schedule.uniqueIdOfMedication inList: possibleMedications];
        schedule.dosage     = [self objectWithId: schedule.uniqueIdOfDosage     inList: possibleDosages];
        schedule.color      = [self objectWithId: schedule.uniqueIdOfColor      inList: possibleColors];
    }
}

+ (NSArray *) allMedications        { return possibleMedications;   }
+ (NSArray *) allDosages            { return possibleDosages;       }
+ (NSArray *) allColors             { return possibleColors;        }
+ (NSArray *) allSampleDosesTaken   { return sampleDosesTaken;      }
+ (NSArray *) allSampleSchedules    { return sampleSchedules;       }

+ (void) saveSchedule: (APCMedicationWeeklySchedule *) schedule
{
    schedule.uniqueIdOfMedication = schedule.medication.uniqueId;
    schedule.uniqueIdOfDosage = schedule.dosage.uniqueId;
    schedule.uniqueIdOfColor = schedule.color.uniqueId;

    [realSchedules addObject: schedule];

    [APCMedicationWeeklySchedule saveObjects: realSchedules
                              toFileWithName: FILE_FOR_REAL_SCHEDULES
                                     onQueue: fileSaveQueue
                           andDoThisWhenDone: ^(BOOL theSaveWorked, NSTimeInterval operationDuration) {

                                      NSLog (@"Did the file-save operation work?  [%@]  It took this many seconds:  %f",
                                             theSaveWorked ? @"YES" : @"NO",
                                             operationDuration);

                                  }];
}



// ---------------------------------------------------------
#pragma mark - Relationships across objects
// ---------------------------------------------------------

/*
 Obviously, I can do these things more effectively.
 I'm trying to get an API working (without CoreData,
 for the moment).
 */

+ (id) objectWithId: (NSNumber *) uniqueId inList: (NSArray *) someList
{
    id result = nil;

    for (id oneItem in someList)
    {
        if ([[oneItem uniqueId] isEqualToNumber: uniqueId])
        {
            result = oneItem;
            break;
        }
    }

    return result;
}

@end








