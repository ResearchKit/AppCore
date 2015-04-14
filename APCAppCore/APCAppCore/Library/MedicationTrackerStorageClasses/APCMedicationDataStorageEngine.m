// 
//  APCMedicationDataStorageEngine.m 
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








