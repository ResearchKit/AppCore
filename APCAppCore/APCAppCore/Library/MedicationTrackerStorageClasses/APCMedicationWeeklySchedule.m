//
//  APCMedicationWeeklySchedule.m
//  AppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCMedicationWeeklySchedule.h"
#import "APCMedicationLozenge.h"
#import "APCMedicationDataStorageEngine.h"

@implementation APCMedicationWeeklySchedule

+ (instancetype) weeklyScheduleWithMedication: (APCMedicationActualMedicine *) medicine
                                       dosage: (APCMedicationPossibleDosage *) dosage
                                        color: (APCMedicationColor *) color
                                daysOfTheWeek: (NSArray *) zeroBasedDaysOfTheWeek
                          numberOfTimesPerDay: (NSNumber *) numberOfTimesPerDay
{
    id result = [[self alloc] initWithMedication: medicine
                                          dosage: dosage
                                           color: color
                                   daysOfTheWeek: zeroBasedDaysOfTheWeek
                             numberOfTimesPerDay: numberOfTimesPerDay];

    return result;
}

- (id) init
{
    self = [super init];

    if (self)
    {
        self.medication = nil;
        self.dosage = nil;
        self.color = nil;
        self.zeroBasedDaysOfTheWeek = nil;
        self.numberOfTimesPerDay = nil;
    }

    return self;
}

- (id) initWithMedication: (APCMedicationActualMedicine *) medicine
                   dosage: (APCMedicationPossibleDosage *) dosage
                    color: (APCMedicationColor *) color
            daysOfTheWeek: (NSArray *) zeroBasedDaysOfTheWeek
      numberOfTimesPerDay: (NSNumber *) numberOfTimesPerDay
{
    self = [self init];

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
    [APCMedicationDataStorageEngine saveSchedule: self];
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
            value = self.numberOfTimesPerDay;
        }

        result [key] = value;
    }

    NSDictionary *immutableResult = [NSDictionary dictionaryWithDictionary: result];
    return immutableResult;
}

- (NSNumber *) dosageCountForSunday    { return [self.zeroBasedDaysOfTheWeek containsObject: @(0)] ? self.numberOfTimesPerDay : 0; }
- (NSNumber *) dosageCountForMonday    { return [self.zeroBasedDaysOfTheWeek containsObject: @(1)] ? self.numberOfTimesPerDay : 0; }
- (NSNumber *) dosageCountForTuesday   { return [self.zeroBasedDaysOfTheWeek containsObject: @(2)] ? self.numberOfTimesPerDay : 0; }
- (NSNumber *) dosageCountForWednesday { return [self.zeroBasedDaysOfTheWeek containsObject: @(3)] ? self.numberOfTimesPerDay : 0; }
- (NSNumber *) dosageCountForThursday  { return [self.zeroBasedDaysOfTheWeek containsObject: @(4)] ? self.numberOfTimesPerDay : 0; }
- (NSNumber *) dosageCountForFriday    { return [self.zeroBasedDaysOfTheWeek containsObject: @(5)] ? self.numberOfTimesPerDay : 0; }
- (NSNumber *) dosageCountForSaturday  { return [self.zeroBasedDaysOfTheWeek containsObject: @(6)] ? self.numberOfTimesPerDay : 0; }

+ (NSString *) nameForZeroBasedDay: (NSNumber *) zeroBasedDayOfTheWeek
{
    NSString *result = nil;

    switch (zeroBasedDayOfTheWeek.integerValue)
    {
        case 0: result = @"Sunday"; break;
        case 1: result = @"Monday"; break;
        case 2: result = @"Tuesday"; break;
        case 3: result = @"Wednesday"; break;
        case 4: result = @"Thursday"; break;
        case 5: result = @"Friday"; break;
        case 6: result = @"Saturday"; break;

        default:
            result = [NSString stringWithFormat: @"unknownDay [%@]", zeroBasedDayOfTheWeek];
            break;
    }

    return result;
}

+ (NSNumber *) zeroBasedDayOfTheWeekForDayName: (NSString *) dayName
{
    NSString* simpleDayName = [[dayName.lowercaseString  stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]] substringToIndex: 3];

    NSNumber* result = ([simpleDayName isEqualToString: @"sun"] ? @(0) :
                        [simpleDayName isEqualToString: @"mon"] ? @(1) :
                        [simpleDayName isEqualToString: @"tue"] ? @(2) :
                        [simpleDayName isEqualToString: @"wed"] ? @(3) :
                        [simpleDayName isEqualToString: @"thu"] ? @(4) :
                        [simpleDayName isEqualToString: @"fri"] ? @(5) :
                        [simpleDayName isEqualToString: @"sat"] ? @(6) :
                        @(-1));

    return result;
}

- (NSArray *) namesOfPropertiesToSave
{
    NSMutableArray *result = [NSMutableArray arrayWithArray: [super namesOfPropertiesToSave]];
    
    [result addObjectsFromArray: @[@"uniqueIdOfMedication",
                                   @"uniqueIdOfDosage",
                                   @"uniqueIdOfColor",
                                   @"zeroBasedDaysOfTheWeek",
                                   @"numberOfTimesPerDay"
                                   ]];
    return result;
}

- (NSString *) description
{
    NSString *result = [NSString stringWithFormat: @"Schedule { uniqueId: %@, medication: %@, days: (%@), timesPerDay: %@, dosage: %@, color: %@ }",
                        self.uniqueId,
                        self.medicationName,
                        [self.zeroBasedDaysOfTheWeek componentsJoinedByString: @","],
                        self.numberOfTimesPerDay,
                        self.dosage.name,
                        self.color
                        ];

    return result;
}

@end











