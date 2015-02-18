//
//  APCMedTrackerMedicationSchedule.m
//  APCAppCore
//
//  Created by Ron Conescu on 2/17/15.
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCMedTrackerMedicationSchedule.h"
#import "APCMedTrackerMedication.h"
#import "APCMedTrackerActualDosageTaken.h"
#import "APCMedTrackerPossibleDosage.h"
#import "APCMedTrackerScheduleColor.h"


@implementation APCMedTrackerMedicationSchedule

@dynamic numberOfTimesPerDay;
@dynamic zeroBasedDaysOfTheWeek;
@dynamic color;
@dynamic dosage;
@dynamic medicine;
@dynamic actualDosesTaken;

@end
