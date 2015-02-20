//
//  APCMedTrackerMedicationSchedule.m
//  AppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCMedTrackerMedicationSchedule.h"
#import "APCMedTrackerActualDosageTaken.h"
#import "APCMedTrackerMedication.h"
#import "APCMedTrackerPossibleDosage.h"
#import "APCMedTrackerScheduleColor.h"


@implementation APCMedTrackerMedicationSchedule

@dynamic numberOfTimesPerDay;
@dynamic zeroBasedDaysOfTheWeek;
@dynamic dateStartedUsing;
@dynamic dateStoppedUsing;
@dynamic didStopUsingOnDoctorsOrders;
@dynamic actualDosesTaken;
@dynamic color;
@dynamic dosage;
@dynamic medicine;

@end
