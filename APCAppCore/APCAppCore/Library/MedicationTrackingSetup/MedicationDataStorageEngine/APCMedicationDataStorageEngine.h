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

+ (NSArray *) allMedications;
+ (NSArray *) allDosages;
+ (NSArray *) allColors;

@end
