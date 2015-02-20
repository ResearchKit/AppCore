//
//  APCMedicationDataStorageEngine.m
//  AppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCMedicationDataStorageEngine.h"
#import "APCMedicationActualMedicine.h"
#import "APCMedicationPossibleDosage.h"
#import "APCMedicationColor.h"

static NSString * const FILE_FOR_PREDEFINED_COLORS = @"APCMedicationPredefinedColors.plist";
static NSString * const FILE_FOR_PREDEFINED_DOSAGES = @"APCMedicationPredefinedDosages.plist";
static NSString * const FILE_FOR_PREDEFINED_MEDICATIONS = @"APCMedicationPredefinedMedications.plist";

static NSArray *possibleMedications = nil;
static NSArray *possibleDosages = nil;
static NSArray *possibleColors = nil;

@implementation APCMedicationDataStorageEngine

+ (void) startup
{
    possibleMedications = [APCMedicationActualMedicine inflatedItemsFromPlistFileWithName: FILE_FOR_PREDEFINED_MEDICATIONS];
    possibleDosages     = [APCMedicationPossibleDosage inflatedItemsFromPlistFileWithName: FILE_FOR_PREDEFINED_DOSAGES];
    possibleColors      = [APCMedicationColor          inflatedItemsFromPlistFileWithName: FILE_FOR_PREDEFINED_COLORS];
}

+ (NSArray *) allMedications { return possibleMedications; }
+ (NSArray *) allDosages     { return possibleDosages;     }
+ (NSArray *) allColors      { return possibleColors;      }

@end
