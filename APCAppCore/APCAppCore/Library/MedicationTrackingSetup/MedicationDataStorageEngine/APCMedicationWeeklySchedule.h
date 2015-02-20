//
//  APCMedicationWeeklySchedule.h
//  AppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APCMedicationColor.h"
#import "APCMedicationActualMedicine.h"
#import "APCMedicationPossibleDosage.h"

@interface APCMedicationWeeklySchedule : NSObject

@property (nonatomic, strong) APCMedicationActualMedicine *medication;
@property (nonatomic, strong) APCMedicationPossibleDosage *dosage;
@property (nonatomic, strong) NSArray *zeroBasedDaysOfTheWeek;
@property (nonatomic, assign) NSUInteger numberOfTimesPerDay;
@property (nonatomic, strong) APCMedicationColor *color;

@property (readonly) NSString *medicationName;
@property (readonly) NSDictionary *frequenciesAndDays;
@property (readonly) NSNumber *dosageValue;
@property (readonly) NSString *dosageText;

+ (instancetype) weeklyScheduleWithMedication: (APCMedicationActualMedicine *) medicine
                                       dosage: (APCMedicationPossibleDosage *) dosage
                                        color: (APCMedicationColor *) color
                                daysOfTheWeek: (NSArray *) zeroBasedDaysOfTheWeek
                          numberOfTimesPerDay: (NSUInteger) numberOfTimesPerDay;

- (void) save;
- (NSArray *) blankLozenges;

@property (readonly) NSUInteger dosageCountForSunday;
@property (readonly) NSUInteger dosageCountForMonday;
@property (readonly) NSUInteger dosageCountForTuesday;
@property (readonly) NSUInteger dosageCountForWednesday;
@property (readonly) NSUInteger dosageCountForThursday;
@property (readonly) NSUInteger dosageCountForFriday;
@property (readonly) NSUInteger dosageCountForSaturday;

@end
