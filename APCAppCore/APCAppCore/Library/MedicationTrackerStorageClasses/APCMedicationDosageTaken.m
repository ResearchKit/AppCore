// 
//  APCMedicationDosageTaken.m 
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
