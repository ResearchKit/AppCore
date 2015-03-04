//
//  APCMedicationDosageTaken.m
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//
#import "APCMedicationDosageTaken.h"

@implementation APCMedicationDosageTaken

+ (instancetype) dosageTakenNowForSchedule: (APCMedicationWeeklySchedule *) schedule
{
    id result = [[self alloc] initWithSchedule: schedule];

    return result;
}

- (id) initWithSchedule: (APCMedicationWeeklySchedule *) schedule
{
    self = [super init];

    if (self)
    {
        self.scheduleIAmBasedOn = schedule;
        self.dateAndTimeDosageWasTaken = [NSDate date];
    }

    return self;
}

- (void) save
{
    NSLog (@"\n"
           "--------------------------------------------------\n"
           "------- Please write -[DosageTaken save] ! -------\n"
           "--------------------------------------------------");

//    NSAssert (NO, @"Dude.  Write -[DosageTaken save].");
}

- (NSString *) description
{
    NSString *result = [NSString stringWithFormat: @"DosageTaken { uniqueId: %@, date: %@, medication: %@ , color: %@, idOfScheduleImBasedOn: %@ (%@) }", self.uniqueId, self.dateAndTimeDosageWasTaken, self.scheduleIAmBasedOn.medicationName, self.scheduleIAmBasedOn.color, self.uniqueIdOfScheduleIAmBasedOn, (self.scheduleIAmBasedOn ? @"o" : @"x")];

    return result;
}

@end
