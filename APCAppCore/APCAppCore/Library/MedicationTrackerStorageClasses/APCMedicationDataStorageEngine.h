//
//  APCMedicationDataStorageEngine.h
//  AppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class APCMedicationWeeklySchedule;

@interface APCMedicationDataStorageEngine : NSObject

+ (void) startup;

// Templates.
+ (NSArray *) allMedications;
+ (NSArray *) allDosages;
+ (NSArray *) allColors;

// History.
+ (NSArray *) allSampleSchedules;
+ (NSArray *) allSampleDosesTaken;

//+ (NSArray *) allSchedulesRecorded;
//+ (NSArray *) allDosesTaken;

+ (void) saveSchedule: (APCMedicationWeeklySchedule *) schedule;



@end
