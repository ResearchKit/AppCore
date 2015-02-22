//
//  APCMedTrackerPrescriptionColor.h
//  AppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "APCMedTrackerInflatableItem.h"

@class APCMedTrackerPrescription;

@interface APCMedTrackerPrescriptionColor : APCMedTrackerInflatableItem

@property (nonatomic, retain) NSNumber * alphaAsFloat;
@property (nonatomic, retain) NSNumber * blueAsInteger;
@property (nonatomic, retain) NSNumber * greenAsInteger;
@property (nonatomic, retain) NSNumber * redAsInteger;
@property (nonatomic, retain) NSSet *prescriptionsWhereIAmUsed;
@end

@interface APCMedTrackerPrescriptionColor (CoreDataGeneratedAccessors)

- (void)addPrescriptionsWhereIAmUsedObject:(APCMedTrackerPrescription *)value;
- (void)removePrescriptionsWhereIAmUsedObject:(APCMedTrackerPrescription *)value;
- (void)addPrescriptionsWhereIAmUsed:(NSSet *)values;
- (void)removePrescriptionsWhereIAmUsed:(NSSet *)values;

@end
