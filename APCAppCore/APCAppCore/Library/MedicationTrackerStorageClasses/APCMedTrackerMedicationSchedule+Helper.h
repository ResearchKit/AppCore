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
                frequenciesAndDays: (NSDictionary *) frequenciesAndDays
                   andUseThisQueue: (NSOperationQueue *) someQueue
                  toDoThisWhenDone: (APCMedTrackerObjectCreationCallbackBlock) callbackBlock;

/*
 Note.  This is the method being called behind the scenes
 for the above.  I'm hiding it because the method name is
 so long that that Xcode's pop-up menu doesn't let us see
 which is which, and the above method name is the one that
 turned out to be needed by the UI.  However, since this
 method tells a more accurate truth of what's being stored,
 I wanted to make sure we don't forget it.

 + (void) newScheduleWithMedication: (APCMedTrackerMedication *) medicine
                             dosage: (APCMedTrackerPossibleDosage *) dosage
                              color: (APCMedTrackerScheduleColor *) color
                      daysOfTheWeek: (NSArray *) zeroBasedDaysOfTheWeek
                numberOfTimesPerDay: (NSNumber *) numberOfTimesPerDay
                    andUseThisQueue: (NSOperationQueue *) someQueue
                   toDoThisWhenDone: (APCMedTrackerObjectCreationCallbackBlock) callbackBlock;
 */

/**
 Returns YES if the schedule is currently active:
 if its dateStoppedUsing field is nil.  Returns NO
 if dateStoppedUsing is non-nil and earlier than
 "now."  This means the default is YES.
 */
@property (readonly) BOOL isActive;

@property (readonly) NSArray *zeroBasedDaysOfTheWeekAsArray;
@property (readonly) NSDictionary *frequenciesAndDays;

//    @property (readonly) NSNumber* dosageCountForSunday;
//    @property (readonly) NSNumber* dosageCountForMonday;
//    @property (readonly) NSNumber* dosageCountForTuesday;
//    @property (readonly) NSNumber* dosageCountForWednesday;
//    @property (readonly) NSNumber* dosageCountForThursday;
//    @property (readonly) NSNumber* dosageCountForFriday;
//    @property (readonly) NSNumber* dosageCountForSaturday;

+ (NSString *) nameForZeroBasedDay: (NSNumber *) zeroBasedDayOfTheWeek;
+ (NSNumber *) zeroBasedDayOfTheWeekForDayName: (NSString *) dayName;


@end
