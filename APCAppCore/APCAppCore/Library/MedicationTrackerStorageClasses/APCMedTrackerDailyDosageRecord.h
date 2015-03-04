//
//  APCMedTrackerDailyDosageRecord.h
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class APCMedTrackerPrescription;

@interface APCMedTrackerDailyDosageRecord : NSManagedObject

@property (nonatomic, retain) NSDate * dateThisRecordRepresents;
@property (nonatomic, retain) NSNumber * numberOfDosesTakenForThisDate;
@property (nonatomic, retain) APCMedTrackerPrescription *prescriptionIAmBasedOn;

@end
