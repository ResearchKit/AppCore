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
#import "APCMedTrackerPossibleDosage+Helper.h"
#import "APCMedTrackerMedication+Helper.h"
#import "APCMedTrackerScheduleColor+Helper.h"


static NSString * const kSeparatorForZeroBasedDaysOfTheWeek = @",";


@implementation APCMedTrackerMedicationSchedule (Helper)

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
            schedule.zeroBasedDaysOfTheWeek = [zeroBasedDaysOfTheWeek componentsJoinedByString: kSeparatorForZeroBasedDaysOfTheWeek];
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

- (NSArray *) zeroBasedDaysOfTheWeekAsArray
{
    NSArray *zeroBasedDaysArray = [self.zeroBasedDaysOfTheWeek componentsSeparatedByString: kSeparatorForZeroBasedDaysOfTheWeek];

    return zeroBasedDaysArray;
}

- (NSDictionary *) frequenciesAndDays
{
    NSMutableDictionary *result = [NSMutableDictionary new];
    NSArray *zeroBasedDaysArray = self.zeroBasedDaysOfTheWeekAsArray;

    for (NSUInteger zeroBasedDayOfWeek = 0; zeroBasedDayOfWeek < 7; zeroBasedDayOfWeek ++)
    {
        NSNumber *key = @(zeroBasedDayOfWeek);
        NSNumber *value = @(0);

        if ([zeroBasedDaysArray containsObject: key])
        {
            value = self.numberOfTimesPerDay;
        }

        result [key] = value;
    }

    NSDictionary *immutableResult = [NSDictionary dictionaryWithDictionary: result];
    return immutableResult;
}

+ (NSString *) nameForZeroBasedDay: (NSNumber *) zeroBasedDayOfTheWeek
{
    NSString *result = nil;

    switch (zeroBasedDayOfTheWeek.integerValue)
    {
        case 0: result = @"Sunday"; break;
        case 1: result = @"Monday"; break;
        case 2: result = @"Tuesday"; break;
        case 3: result = @"Wednesday"; break;
        case 4: result = @"Thursday"; break;
        case 5: result = @"Friday"; break;
        case 6: result = @"Saturday"; break;

        default:
            result = [NSString stringWithFormat: @"unknownDay [%@]", zeroBasedDayOfTheWeek];
            break;
    }

    return result;
}

+ (NSNumber *) zeroBasedDayOfTheWeekForDayName: (NSString *) dayName
{
    NSString* simpleDayName = [[dayName.lowercaseString  stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]] substringToIndex: 3];

    NSNumber* result = ([simpleDayName isEqualToString: @"sun"] ? @(0) :
                        [simpleDayName isEqualToString: @"mon"] ? @(1) :
                        [simpleDayName isEqualToString: @"tue"] ? @(2) :
                        [simpleDayName isEqualToString: @"wed"] ? @(3) :
                        [simpleDayName isEqualToString: @"thu"] ? @(4) :
                        [simpleDayName isEqualToString: @"fri"] ? @(5) :
                        [simpleDayName isEqualToString: @"sat"] ? @(6) :
                        @(-1));
    
    return result;
}

- (NSString *) description
{
    NSString *result = [NSString stringWithFormat: @"Schedule { medication: %@, days: (%@), timesPerDay: %@, dosage: %@, color: %@ }",
                        self.self.medicine.name,
                        self.zeroBasedDaysOfTheWeek,
                        self.numberOfTimesPerDay,
                        self.dosage.name,
                        self.color.name
                        ];

    return result;
}


@end
