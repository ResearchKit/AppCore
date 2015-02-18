//
//  APCMedTrackerMedicationSchedule.h
//  APCAppCore
//
//  Created by Ron Conescu on 2/18/15.
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class APCMedTrackerActualDosageTaken, APCMedTrackerMedication, APCMedTrackerPossibleDosage, APCMedTrackerScheduleColor;

@interface APCMedTrackerMedicationSchedule : NSManagedObject

@property (nonatomic, retain) NSNumber * numberOfTimesPerDay;
@property (nonatomic, retain) NSString * zeroBasedDaysOfTheWeek;
@property (nonatomic, retain) NSDate * dateStartedUsing;
@property (nonatomic, retain) NSDate * dateStoppedUsing;
@property (nonatomic, retain) NSNumber * didStopUsingOnDoctorsOrders;
@property (nonatomic, retain) NSSet *actualDosesTaken;
@property (nonatomic, retain) APCMedTrackerScheduleColor *color;
@property (nonatomic, retain) APCMedTrackerPossibleDosage *dosage;
@property (nonatomic, retain) APCMedTrackerMedication *medicine;
@end

@interface APCMedTrackerMedicationSchedule (CoreDataGeneratedAccessors)

- (void)addActualDosesTakenObject:(APCMedTrackerActualDosageTaken *)value;
- (void)removeActualDosesTakenObject:(APCMedTrackerActualDosageTaken *)value;
- (void)addActualDosesTaken:(NSSet *)values;
- (void)removeActualDosesTaken:(NSSet *)values;

@end
