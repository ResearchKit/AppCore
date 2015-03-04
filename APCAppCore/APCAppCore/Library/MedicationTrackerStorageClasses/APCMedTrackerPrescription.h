//
//  APCMedTrackerPrescription.h
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class APCMedTrackerDailyDosageRecord, APCMedTrackerMedication, APCMedTrackerPossibleDosage, APCMedTrackerPrescriptionColor;

@interface APCMedTrackerPrescription : NSManagedObject

@property (nonatomic, retain) NSDate * dateStartedUsing;
@property (nonatomic, retain) NSDate * dateStoppedUsing;
@property (nonatomic, retain) NSNumber * didStopUsingOnDoctorsOrders;
@property (nonatomic, retain) NSNumber * numberOfTimesPerDay;
@property (nonatomic, retain) NSString * zeroBasedDaysOfTheWeek;
@property (nonatomic, retain) NSSet *actualDosesTaken;
@property (nonatomic, retain) APCMedTrackerPrescriptionColor *color;
@property (nonatomic, retain) APCMedTrackerPossibleDosage *dosage;
@property (nonatomic, retain) APCMedTrackerMedication *medication;
@end

@interface APCMedTrackerPrescription (CoreDataGeneratedAccessors)

- (void)addActualDosesTakenObject:(APCMedTrackerDailyDosageRecord *)value;
- (void)removeActualDosesTakenObject:(APCMedTrackerDailyDosageRecord *)value;
- (void)addActualDosesTaken:(NSSet *)values;
- (void)removeActualDosesTaken:(NSSet *)values;

@end
