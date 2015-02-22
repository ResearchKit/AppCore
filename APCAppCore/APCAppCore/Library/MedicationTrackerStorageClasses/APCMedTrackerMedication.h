//
//  APCMedTrackerMedication.h
//  APCAppCore
//
//  Created by Ron Conescu on 2/22/15.
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "APCMedTrackerInflatableItem.h"

@class APCMedTrackerPrescription;

@interface APCMedTrackerMedication : APCMedTrackerInflatableItem

@property (nonatomic, retain) NSSet *prescriptionsWhereIAmUsed;
@end

@interface APCMedTrackerMedication (CoreDataGeneratedAccessors)

- (void)addPrescriptionsWhereIAmUsedObject:(APCMedTrackerPrescription *)value;
- (void)removePrescriptionsWhereIAmUsedObject:(APCMedTrackerPrescription *)value;
- (void)addPrescriptionsWhereIAmUsed:(NSSet *)values;
- (void)removePrescriptionsWhereIAmUsed:(NSSet *)values;

@end
