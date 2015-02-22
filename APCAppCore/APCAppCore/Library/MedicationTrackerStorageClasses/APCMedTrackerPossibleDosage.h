//
//  APCMedTrackerPossibleDosage.h
//  AppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "APCMedTrackerInflatableItem.h"

@class APCMedTrackerMedicationSchedule;

@interface APCMedTrackerPossibleDosage : APCMedTrackerInflatableItem

@property (nonatomic, retain) NSNumber * amount;
@property (nonatomic, retain) NSSet *schedulesWhereIAmUsed;
@end

@interface APCMedTrackerPossibleDosage (CoreDataGeneratedAccessors)

- (void)addSchedulesWhereIAmUsedObject:(APCMedTrackerMedicationSchedule *)value;
- (void)removeSchedulesWhereIAmUsedObject:(APCMedTrackerMedicationSchedule *)value;
- (void)addSchedulesWhereIAmUsed:(NSSet *)values;
- (void)removeSchedulesWhereIAmUsed:(NSSet *)values;

@end
