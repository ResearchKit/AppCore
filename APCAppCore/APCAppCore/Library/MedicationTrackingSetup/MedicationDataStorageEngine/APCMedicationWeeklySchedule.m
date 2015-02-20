//
//  APCMedicationWeeklySchedule.m
//  AppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCMedicationWeeklySchedule.h"
#import "APCMedicationLozenge.h"

@implementation APCMedicationWeeklySchedule

+ (instancetype) weeklyScheduleWithMedication: (APCMedicationActualMedicine *) medicine
                                       dosage: (APCMedicationPossibleDosage *) dosage
                                        color: (APCMedicationColor *) color
                                daysOfTheWeek: (NSArray *) zeroBasedDaysOfTheWeek
                          numberOfTimesPerDay: (NSUInteger) numberOfTimesPerDay
{
    id result = [[self alloc] initWithMedication: medicine
                                          dosage: dosage
                                           color: color
                                   daysOfTheWeek: zeroBasedDaysOfTheWeek
                             numberOfTimesPerDay: numberOfTimesPerDay];

    return result;
}

- (id) initWithMedication: (APCMedicationActualMedicine *) medicine
                   dosage: (APCMedicationPossibleDosage *) dosage
                    color: (APCMedicationColor *) color
            daysOfTheWeek: (NSArray *) zeroBasedDaysOfTheWeek
      numberOfTimesPerDay: (NSUInteger) numberOfTimesPerDay
{
    self = [super init];

    if (self)
    {
        self.medication = medicine;
        self.dosage = dosage;
        self.color = color;
        self.zeroBasedDaysOfTheWeek = zeroBasedDaysOfTheWeek;
        self.numberOfTimesPerDay = numberOfTimesPerDay;
    }

    return self;
}

- (void) save
{
    NSLog (@"\n"
           "-----------------------------------------------\n"
           "------- Please write -[Schedule save] ! -------\n"
           "-----------------------------------------------");

//    NSAssert (NO, @"Dude.  Write -[Schedule save], please.");
}

- (NSArray *) blankLozenges
{
    NSMutableArray *lozenges = [NSMutableArray new];
    APCMedicationLozenge *lozenge = nil;

    for (NSNumber *zeroBasedDayOfWeek in self.zeroBasedDaysOfTheWeek)
    {
        lozenge = [APCMedicationLozenge lozengeWithSchedule: self
                                               dayOfTheWeek: zeroBasedDayOfWeek
                                           maxNumberOfDoses: self.numberOfTimesPerDay];

        [lozenges addObject: lozenge];
    }

    return lozenges;
}

- (NSString *) medicationName
{
    return self.medication.name;
}

- (NSNumber *) dosageValue
{
    return self.dosage.amount;
}

- (NSString *) dosageText
{
    return self.dosage.name;
}

/**
 This is a very user-specific API:  before we wrote
 this storage engine, we had already decided to use
 the data structure below when making stuff appear
 on a screen.
 */
- (NSDictionary *) frequenciesAndDays
{
    NSMutableDictionary *result = [NSMutableDictionary new];

    for (NSUInteger zeroBasedDayOfWeek = 0; zeroBasedDayOfWeek < 7; zeroBasedDayOfWeek ++)
    {
        NSNumber *key = @(zeroBasedDayOfWeek);
        NSNumber *value = @(0);

        if ([self.zeroBasedDaysOfTheWeek containsObject: key])
        {
            value = @(self.numberOfTimesPerDay);
        }

        result [key] = value;
    }

    NSDictionary *immutableResult = [NSDictionary dictionaryWithDictionary: result];
    return immutableResult;
}

- (NSUInteger) dosageCountForSunday    { return [self.zeroBasedDaysOfTheWeek containsObject: @(0)] ? self.numberOfTimesPerDay : 0; }
- (NSUInteger) dosageCountForMonday    { return [self.zeroBasedDaysOfTheWeek containsObject: @(1)] ? self.numberOfTimesPerDay : 0; }
- (NSUInteger) dosageCountForTuesday   { return [self.zeroBasedDaysOfTheWeek containsObject: @(2)] ? self.numberOfTimesPerDay : 0; }
- (NSUInteger) dosageCountForWednesday { return [self.zeroBasedDaysOfTheWeek containsObject: @(3)] ? self.numberOfTimesPerDay : 0; }
- (NSUInteger) dosageCountForThursday  { return [self.zeroBasedDaysOfTheWeek containsObject: @(4)] ? self.numberOfTimesPerDay : 0; }
- (NSUInteger) dosageCountForFriday    { return [self.zeroBasedDaysOfTheWeek containsObject: @(5)] ? self.numberOfTimesPerDay : 0; }
- (NSUInteger) dosageCountForSaturday  { return [self.zeroBasedDaysOfTheWeek containsObject: @(6)] ? self.numberOfTimesPerDay : 0; }

@end











