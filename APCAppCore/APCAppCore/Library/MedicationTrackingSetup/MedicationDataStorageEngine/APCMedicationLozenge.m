//
//  APCMedicationLozenge.m
//  AppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCMedicationLozenge.h"
#import "APCMedicationWeeklySchedule.h"
#import "APCMedicationDosageTaken.h"

@implementation APCMedicationLozenge

+ (instancetype) lozengeWithSchedule: (APCMedicationWeeklySchedule *) schedule
                        dayOfTheWeek: (NSNumber *) zeroBasedDayOfTheWeek
                    maxNumberOfDoses: (NSUInteger) maxNumberOfDoses
{
    id result = [[self alloc] initWithSchedule: schedule
                                  dayOfTheWeek: zeroBasedDayOfTheWeek
                              maxNumberOfDoses: maxNumberOfDoses];

    return result;
}

- (id) initWithSchedule: (APCMedicationWeeklySchedule *) schedule
           dayOfTheWeek: (NSNumber *) zeroBasedDayOfTheWeek
       maxNumberOfDoses: (NSUInteger) maxNumberOfDoses
{
    self = [super init];

    if (self)
    {
        self.schedule = schedule;
        self.zeroBasedDayOfTheWeek = zeroBasedDayOfTheWeek;
        self.dosesTakenSoFar = 0;
        self.maxNumberOfDoses = maxNumberOfDoses;
    }

    return self;
}

- (APCMedicationDosageTaken *) takeDoseNowAndSave
{
    APCMedicationDosageTaken *dosageTaken = [APCMedicationDosageTaken dosageTakenNowForSchedule: self.schedule];

    self.dosesTakenSoFar = self.dosesTakenSoFar + 1;

    [dosageTaken save];

    return dosageTaken;
}

- (NSString *) description
{
    NSString *result = [NSString stringWithFormat: @"Lozenge { color: %@, dayOfWeek: %@, dosesSoFar: %d, maxDoses: %d, isComplete: %@ }",
                        self.schedule.color,
                        self.zeroBasedDayOfTheWeek,
                        (int) self.dosesTakenSoFar,
                        (int) self.maxNumberOfDoses,
                        self.isComplete ? @"YES" : @"NO"
                        ];

    return result;
}

@end







