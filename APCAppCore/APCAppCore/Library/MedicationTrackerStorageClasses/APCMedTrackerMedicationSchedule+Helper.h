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


typedef void (^APCMedTrackerObjectCreationCallbackBlock) (id createdObject, NSTimeInterval operationDuration, NSManagedObjectContext *theContextWeSavedOn, NSManagedObjectID *scheduleObjectId);



@interface APCMedTrackerMedicationSchedule (Helper)

@property (readonly) NSString *medicationName;

+ (void) newScheduleWithMedication: (APCMedTrackerMedication *) medicine
                            dosage: (APCMedTrackerPossibleDosage *) dosage
                             color: (APCMedTrackerScheduleColor *) color
                     daysOfTheWeek: (NSArray *) zeroBasedDaysOfTheWeek
               numberOfTimesPerDay: (NSNumber *) numberOfTimesPerDay
                   andUseThisQueue: (NSOperationQueue *) someQueue
                  toDoThisWhenDone: (APCMedTrackerObjectCreationCallbackBlock) callbackBlock;

+ (NSArray *) schedulesForCurrentWeek;

/**
 Returns YES if the schedule is currently active:
 if its dateStoppedUsing field is nil.  Returns NO
 if dateStoppedUsing is non-nil and earlier than
 "now."  This means the default is YES.
 */
@property (readonly) BOOL isActive;

@end
