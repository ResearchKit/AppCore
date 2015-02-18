//
//  APCMedTrackerActualDosageTaken.h
//  APCAppCore
//
//  Created by Ron Conescu on 2/17/15.
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class APCMedTrackerMedicationSchedule;

@interface APCMedTrackerActualDosageTaken : NSManagedObject

@property (nonatomic, retain) NSDate * dateAndTimeDosageWasTaken;
@property (nonatomic, retain) APCMedTrackerMedicationSchedule *scheduleIAmBasedOn;

@end
