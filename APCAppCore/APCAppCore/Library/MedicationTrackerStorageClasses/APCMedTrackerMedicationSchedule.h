//
//  APCMedTrackerMedicationSchedule.h
//  APCAppCore
//
//  Created by Ron Conescu on 2/17/15.
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class APCMedTrackerMedication, APCMedTrackerActualDosageTaken, APCMedTrackerPossibleDosage, APCMedTrackerScheduleColor;

@interface APCMedTrackerMedicationSchedule : NSManagedObject

@property (nonatomic, retain) NSNumber * numberOfTimesPerDay;
@property (nonatomic, retain) NSString * zeroBasedDaysOfTheWeek;
@property (nonatomic, retain) APCMedTrackerScheduleColor *color;
@property (nonatomic, retain) APCMedTrackerPossibleDosage *dosage;
@property (nonatomic, retain) APCMedTrackerMedication *medicine;
@property (nonatomic, retain) NSSet *actualDosesTaken;

@end

@interface APCMedTrackerMedicationSchedule (CoreDataGeneratedAccessors)

- (void)addActualDosesTakenObject:(APCMedTrackerActualDosageTaken *)value;
- (void)removeActualDosesTakenObject:(APCMedTrackerActualDosageTaken *)value;
- (void)addActualDosesTaken:(NSSet *)values;
- (void)removeActualDosesTaken:(NSSet *)values;

@end
