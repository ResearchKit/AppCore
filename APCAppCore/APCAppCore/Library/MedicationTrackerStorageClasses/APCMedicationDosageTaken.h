//
//  APCMedicationDosageTaken.h
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCMedicationUltraSimpleSelfInflator.h"
#import "APCMedicationWeeklySchedule.h"

@interface APCMedicationDosageTaken : APCMedicationUltraSimpleSelfInflator

@property (nonatomic, strong) APCMedicationWeeklySchedule *scheduleIAmBasedOn;
@property (nonatomic, strong) NSDate *dateAndTimeDosageWasTaken;

+ (instancetype) dosageTakenNowForSchedule: (APCMedicationWeeklySchedule *) schedule;

- (void) save;


/*
 Extra data for storing and retrieving from disk.
 This name is significant, in my little world:
 - "uniqueId" is a known prefix.
 - "uniqueIdOfXXXX" says:  please find and load the property of name XXXX with
   the specified ID.  (I think.  Evolving.)
 */
@property (nonatomic, strong) NSNumber *uniqueIdOfScheduleIAmBasedOn;

@end
