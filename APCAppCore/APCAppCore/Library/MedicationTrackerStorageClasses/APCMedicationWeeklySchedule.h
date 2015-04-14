// 
//  APCMedicationWeeklySchedule.h 
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
