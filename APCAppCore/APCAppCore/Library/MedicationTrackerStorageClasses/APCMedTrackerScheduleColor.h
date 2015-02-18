//
//  APCMedTrackerScheduleColor.h
//  APCAppCore
//
//  Created by Ron Conescu on 2/17/15.
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class APCMedTrackerMedicationSchedule;

@interface APCMedTrackerScheduleColor : NSManagedObject

@property (nonatomic, retain) NSNumber * alphaAsFloat;
@property (nonatomic, retain) NSNumber * blueAsInteger;
@property (nonatomic, retain) NSNumber * greenAsInteger;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * redAsInteger;
@property (nonatomic, retain) NSSet *schedulesWhereIAmUsed;
@end

@interface APCMedTrackerScheduleColor (CoreDataGeneratedAccessors)

- (void)addSchedulesWhereIAmUsedObject:(APCMedTrackerMedicationSchedule *)value;
- (void)removeSchedulesWhereIAmUsedObject:(APCMedTrackerMedicationSchedule *)value;
- (void)addSchedulesWhereIAmUsed:(NSSet *)values;
- (void)removeSchedulesWhereIAmUsed:(NSSet *)values;

@end
