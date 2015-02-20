//
//  APCMedicationDosageTaken.h
//  AppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APCMedicationWeeklySchedule.h"

@interface APCMedicationDosageTaken : NSObject

@property (nonatomic, strong) APCMedicationWeeklySchedule *scheduleIAmBasedOn;
@property (nonatomic, strong) NSDate *dateAndTimeDosageWasTaken;

+ (instancetype) dosageTakenNowForSchedule: (APCMedicationWeeklySchedule *) schedule;

- (void) save;

@end
