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
                frequenciesAndDays: (NSDictionary *) frequenciesAndDays
                   andUseThisQueue: (NSOperationQueue *) someQueue
                  toDoThisWhenDone: (APCMedTrackerObjectCreationCallbackBlock) callbackBlock
{
    NSNumber *numberOfTimesPerDay = nil;
    NSMutableArray *zeroBasedDaysOfTheWeek = [NSMutableArray new];

    // Find the number of times per day:  the first non-zero entry.
    // By definition, all days have the same number of times per day.
    for (id thingy in frequenciesAndDays.allValues)
    {
        if ([thingy isKindOfClass: [NSNumber class]])
        {
            numberOfTimesPerDay = thingy;

            if (numberOfTimesPerDay.integerValue > 0)
            {
                // Found.
                break;
            }
        }
    }

    // Create a list of the zero-based days of the week.
    for (NSString *key in frequenciesAndDays.allKeys)
    {
        id value = frequenciesAndDays [key];

        if ([value isKindOfClass: [NSNumber class]])
        {
            NSInteger valueAsInt = ((NSNumber *) value).integerValue;

            if (valueAsInt > 0)
            {
                // Found a day with a required dosage in it.  Capture it.
                NSString *theDayWeWantToKeep = key;
                NSNumber *zeroBasedIndexOfThatDay = [self zeroBasedDayOfTheWeekForDayName: theDayWeWantToKeep];
                [zeroBasedDaysOfTheWeek addObject: zeroBasedIndexOfThatDay];
            }
        }
    }

    // Create it.
    [self newScheduleWithMedication: medicine
                             dosage: dosage
                              color: color
                      daysOfTheWeek: zeroBasedDaysOfTheWeek
                numberOfTimesPerDay: numberOfTimesPerDay
                    andUseThisQueue: someQueue
                   toDoThisWhenDone: callbackBlock];
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

/**
 This code is identical to the code found in the APCMedTrackerInflatableItem classes.
 I haven't yet unified those and this into a common superclass.  I'm getting there.
 */
+ (void) fetchAllFromCoreDataAndUseThisQueue: (NSOperationQueue *) someQueue
                            toDoThisWhenDone: (APCMedTrackerQueryCallback2) callbackBlock
{
    [APCMedTrackerDataStorageManager.defaultManager.queue addOperationWithBlock:^{

        NSDate *startTime = [NSDate date];

        NSManagedObjectContext *context = APCMedTrackerDataStorageManager.defaultManager.context;

        // Fetch all items of my current subclass.
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName: NSStringFromClass ([self class])];

        NSError *error = nil;
        NSArray *foundItems = [context executeFetchRequest: request error: &error];

        NSTimeInterval operationDuration = [[NSDate date] timeIntervalSinceDate: startTime];

        /**
         Pass the buck.  ...uh, pass the error to the target block.
         :-)  See the explanation of APCMedTrackerQueryCallback2 for
         how the parameters should be used.
         */
        if (someQueue != nil && callbackBlock != NULL)
        {
            [someQueue addOperationWithBlock: ^{
                callbackBlock (foundItems, operationDuration, error);
            }];
        }
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
    /*
     Convert from a string like "4,1" to "Monday, Thursday":
     - original: "4,1"
     - split: "4", "1"
     - sort: "1", "4"
     - numbers: 1, 4
     - names: "Monday", "Thursday"
     - unified string: "Monday, Thursday"
     */
    NSArray *zeroBasedDaysOfTheWeekArray = self.zeroBasedDaysOfTheWeekAsArray;
    zeroBasedDaysOfTheWeekArray = [zeroBasedDaysOfTheWeekArray sortedArrayUsingSelector: @selector(compare:)];
    NSMutableArray *dayNames = [NSMutableArray new];
    for (NSString *item in zeroBasedDaysOfTheWeekArray)
    {
        NSInteger dayNumber = item.integerValue;
        NSString *dayName = [[self class] nameForZeroBasedDay: @(dayNumber)];
        [dayNames addObject: dayName];
    }

    NSString *result = [NSString stringWithFormat: @"Schedule { medication: %@, days: (%@), timesPerDay: %@, dosage: %@, color: %@ }",
                        self.self.medicine.name,
                        [dayNames componentsJoinedByString: @", "],
                        self.numberOfTimesPerDay,
                        self.dosage.name,
                        self.color.name
                        ];

    return result;
}


@end
