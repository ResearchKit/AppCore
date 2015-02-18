//
//  APCMedTrackerMedicationSchedule+Helper.m
//  APCAppCore
//
//  Created by Ron Conescu on 2/17/15.
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCMedTrackerMedicationSchedule+Helper.h"
#import "APCMedTrackerMedication.h"
#import "NSManagedObject+APCHelper.h"
#import "APCAppDelegate.h"
#import "APCDataSubstrate+CoreData.h"
#import "NSManagedObject+APCHelper.h"
#import "NSDate+Helper.h"

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
    // This is our pattern for creating and saving objects.
    [someQueue addOperationWithBlock:^{

        NSDate *startTime = [NSDate date];
        APCAppDelegate *appDelegate = (APCAppDelegate *) [[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *masterContextIThink = appDelegate.dataSubstrate.persistentContext;

        NSManagedObjectContext *localContext = [[NSManagedObjectContext alloc] initWithConcurrencyType: NSPrivateQueueConcurrencyType];
        localContext.parentContext = masterContextIThink;

//      [localContext performBlockAndWait: ^{
        [localContext performBlock: ^{

            APCMedTrackerMedicationSchedule *schedule = [APCMedTrackerMedicationSchedule newObjectForContext: localContext];

            schedule.medicine = medicine;
            schedule.dosage = dosage;
            schedule.color = color;
            schedule.zeroBasedDaysOfTheWeek = [zeroBasedDaysOfTheWeek componentsJoinedByString: @","];
            schedule.numberOfTimesPerDay = numberOfTimesPerDay;
            schedule.dateStartedUsing = [NSDate date];

            NSError *error = nil;
//            [schedule saveToPersistentStore: &error];

            if (localContext.hasChanges)
            {
                if ([localContext save: &error])
                {
                    NSLog (@"Save seems to have worked!");
                }
                else
                {
                    NSLog (@"Error while saving!  %@", error);
                }
            }
            else
            {
                NSLog (@"Dude.  Nothing to save.  'sup widdat?");
            }

            NSTimeInterval operationDuration = [[NSDate date] timeIntervalSinceDate: startTime];

            [someQueue addOperationWithBlock: ^{
                callbackBlock (schedule, operationDuration, localContext, schedule.objectID);
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
