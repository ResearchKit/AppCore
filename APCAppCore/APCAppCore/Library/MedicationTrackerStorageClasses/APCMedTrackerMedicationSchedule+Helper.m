//
//  APCMedTrackerMedicationSchedule+Helper.m
//  AppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCMedTrackerMedicationSchedule+Helper.h"
#import "APCMedTrackerMedication.h"
#import "NSManagedObject+APCHelper.h"
#import "APCAppDelegate.h"
#import "APCDataSubstrate+CoreData.h"
#import "NSManagedObject+APCHelper.h"
#import "NSDate+Helper.h"
#import "APCMedTrackerDataStorageManager.h"

@implementation APCMedTrackerMedicationSchedule (Helper)

- (NSString *) medicationName
{
    return self.medicine.name;
}

+ (void) newScheduleWithMedication: (APCMedTrackerMedication *) medicine
                            dosage: (APCMedTrackerPossibleDosage *) dosage
                             color: (APCMedTrackerScheduleColor *) color
                     daysOfTheWeek: (NSArray *) zeroBasedDaysOfTheWeek
               numberOfTimesPerDay: (NSNumber *) numberOfTimesPerDay
                   andUseThisQueue: (NSOperationQueue *) someQueue
                  toDoThisWhenDone: (APCMedTrackerObjectCreationCallbackBlock) callbackBlock
{
    [[[APCMedTrackerDataStorageManager defaultManager] queue] addOperationWithBlock:^{

        NSDate *startTime = [NSDate date];
        NSManagedObjectContext *localContext = [[APCMedTrackerDataStorageManager defaultManager] context];

        //
        // We can also use -performBlockAndWait:.
        //
        [localContext performBlock: ^{

            APCMedTrackerMedicationSchedule *schedule = [APCMedTrackerMedicationSchedule newObjectForContext: localContext];

            schedule.medicine = medicine;
            schedule.dosage = dosage;
            schedule.color = color;
            schedule.zeroBasedDaysOfTheWeek = [zeroBasedDaysOfTheWeek componentsJoinedByString: @","];
            schedule.numberOfTimesPerDay = numberOfTimesPerDay;
            schedule.dateStartedUsing = [NSDate date];

            NSError *error = nil;
            BOOL itWorked = [schedule saveToPersistentStore: &error];

            if (itWorked)
            {
                // Not sure how we're going to handle this, yet.  This method is still evolving.
            }
            else if (error == nil)
            {

            }
            else
            {

            }

            NSTimeInterval operationDuration = [[NSDate date] timeIntervalSinceDate: startTime];

            // Report.
            [someQueue addOperationWithBlock: ^{
                callbackBlock (schedule, operationDuration);
            }];
        }];
    }];
}

+ (NSArray *) schedulesForCurrentWeek
{
    NSArray *result = nil;

    return result;
}

- (BOOL) isActive
{
    BOOL result = YES;

    if (self.dateStoppedUsing != nil && self.dateStoppedUsing.isInThePast)
    {
        result = NO;
    }

    return result;
}


@end
