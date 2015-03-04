//
//  APCMedTrackerPrescription.m
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
//

#import "APCMedTrackerPrescription.h"
#import "APCMedTrackerDailyDosageRecord.h"
#import "APCMedTrackerMedication.h"
#import "APCMedTrackerPossibleDosage.h"
#import "APCMedTrackerPrescriptionColor.h"


@implementation APCMedTrackerPrescription

@dynamic dateStartedUsing;
@dynamic dateStoppedUsing;
@dynamic didStopUsingOnDoctorsOrders;
@dynamic numberOfTimesPerDay;
@dynamic zeroBasedDaysOfTheWeek;
@dynamic actualDosesTaken;
@dynamic color;
@dynamic dosage;
@dynamic medication;

@end
