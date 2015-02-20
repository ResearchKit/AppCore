//
//  APCMedTrackerMedicationSchedule+Helper.h
//  AppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCMedTrackerMedicationSchedule.h"
@class APCMedTrackerMedication;
@class APCMedTrackerPossibleDosage;
@class APCMedTrackerScheduleColor;


typedef void (^APCMedTrackerObjectCreationCallbackBlock) (id createdObject, NSTimeInterval operationDuration);



@interface APCMedTrackerMedicationSchedule (Helper)

+ (void) newScheduleWithMedication: (APCMedTrackerMedication *) medicine
                            dosage: (APCMedTrackerPossibleDosage *) dosage
                             color: (APCMedTrackerScheduleColor *) color
                     daysOfTheWeek: (NSArray *) zeroBasedDaysOfTheWeek
               numberOfTimesPerDay: (NSNumber *) numberOfTimesPerDay
                   andUseThisQueue: (NSOperationQueue *) someQueue
                  toDoThisWhenDone: (APCMedTrackerObjectCreationCallbackBlock) callbackBlock;


//    + (NSArray *) schedulesForCurrentWeek;
//    - (NSArray *) blankLozenges;


/**
 Returns YES if the schedule is currently active:
 if its dateStoppedUsing field is nil.  Returns NO
 if dateStoppedUsing is non-nil and earlier than
 "now."  This means the default is YES.
 */
@property (readonly) BOOL isActive;

@property (readonly) NSArray *zeroBasedDaysOfTheWeekAsArray;
@property (readonly) NSDictionary *frequenciesAndDays;

@property (readonly) NSNumber* dosageCountForSunday;
@property (readonly) NSNumber* dosageCountForMonday;
@property (readonly) NSNumber* dosageCountForTuesday;
@property (readonly) NSNumber* dosageCountForWednesday;
@property (readonly) NSNumber* dosageCountForThursday;
@property (readonly) NSNumber* dosageCountForFriday;
@property (readonly) NSNumber* dosageCountForSaturday;

+ (NSString *) nameForZeroBasedDay: (NSNumber *) zeroBasedDayOfTheWeek;
+ (NSNumber *) zeroBasedDayOfTheWeekForDayName: (NSString *) dayName;


@end
