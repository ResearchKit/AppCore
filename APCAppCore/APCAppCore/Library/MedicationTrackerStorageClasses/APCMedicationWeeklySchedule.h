//
//  APCMedicationWeeklySchedule.h
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCMedicationUltraSimpleSelfInflator.h"
#import "APCMedicationColor.h"
#import "APCMedicationActualMedicine.h"
#import "APCMedicationPossibleDosage.h"

@class APCMedicationLozenge;


@interface APCMedicationWeeklySchedule : APCMedicationUltraSimpleSelfInflator

/** My real data. */
@property (nonatomic, strong) APCMedicationActualMedicine *medication;
@property (nonatomic, strong) APCMedicationPossibleDosage *dosage;
@property (nonatomic, strong) NSArray *zeroBasedDaysOfTheWeek;
@property (nonatomic, strong) NSNumber *numberOfTimesPerDay;
@property (nonatomic, strong) APCMedicationColor *color;

/** Properties for storing/retrieving to/from disk. */
@property (nonatomic, strong) NSNumber *uniqueIdOfMedication;
@property (nonatomic, strong) NSNumber *uniqueIdOfDosage;
@property (nonatomic, strong) NSNumber *uniqueIdOfColor;

@property (readonly) NSString *medicationName;
@property (readonly) NSDictionary *frequenciesAndDays;
@property (readonly) NSNumber *dosageValue;
@property (readonly) NSString *dosageText;

+ (instancetype) weeklyScheduleWithMedication: (APCMedicationActualMedicine *) medicine
                                       dosage: (APCMedicationPossibleDosage *) dosage
                                        color: (APCMedicationColor *) color
                                daysOfTheWeek: (NSArray *) zeroBasedDaysOfTheWeek
                          numberOfTimesPerDay: (NSNumber *) numberOfTimesPerDay;

- (void) save;
- (NSArray *) blankLozenges;

@property (readonly) NSNumber* dosageCountForSunday;
@property (readonly) NSNumber* dosageCountForMonday;
@property (readonly) NSNumber* dosageCountForTuesday;
@property (readonly) NSNumber* dosageCountForWednesday;
@property (readonly) NSNumber* dosageCountForThursday;
@property (readonly) NSNumber* dosageCountForFriday;
@property (readonly) NSNumber* dosageCountForSaturday;

+ (NSString *) nameForZeroBasedDay: (NSNumber *) zeroBasedDayOfTheWeek;
+ (NSNumber *) zeroBasedDayOfTheWeekForDayName: (NSString *) dayName;

@end
