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


/**
 The +fetchAll methods will call you back when
 they're done, using a block with this signature.

 Note that "arrayOfGeneratedObjects" and "error" are
 passed to you straight from the output of a CoreData
 "fetch request."  This means we have to interpret them
 in precise ways:
 - the array will be nil if there was an error
 - the array will have stuff in it if there was stuff to be found
 - the array will be empty if there were no items of the type you
 requested.  You may consider this an error -- it depends on
 your business logic.

 Please see -[NSManagedObjectContext executeFetchRequest:]
 for a formal and complete description of those rules.
 
 This type is called "...2" because I haven't yet unified
 the classes which need it so that they have a common
 superclass.  Gettin' there...
 */
typedef void (^APCMedTrackerQueryCallback2) (NSArray *arrayOfGeneratedObjects,
                                             NSTimeInterval operationDuration,
                                             NSError *error);




@interface APCMedTrackerMedicationSchedule (Helper)

+ (void) newScheduleWithMedication: (APCMedTrackerMedication *) medicine
                            dosage: (APCMedTrackerPossibleDosage *) dosage
                             color: (APCMedTrackerScheduleColor *) color
                  frequencyAndDays: (NSDictionary *) frequencyAndDays
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
 Runs a query which loads all objects of this class in CoreData.
 Passes that array back to you in the block you specify.

 This merely loads a fetch request and extracts all items from it.
 It can easily be done in other ways.
 */
+ (void) fetchAllFromCoreDataAndUseThisQueue: (NSOperationQueue *) someQueue
                            toDoThisWhenDone: (APCMedTrackerQueryCallback2) callbackBlock;


/**
 Returns YES if the schedule is currently active:
 if its dateStoppedUsing field is nil.  Returns NO
 if dateStoppedUsing is non-nil and earlier than
 "now."  This means the default is YES.
 */
@property (readonly) BOOL isActive;

@property (readonly) NSArray *zeroBasedDaysOfTheWeekAsArrayOfSortedNumbers;
@property (readonly) NSDictionary *frequencyAndDays;

+ (NSString *) nameForZeroBasedDay: (NSNumber *) zeroBasedDayOfTheWeek;
+ (NSNumber *) zeroBasedDayOfTheWeekForDayName: (NSString *) dayName;


@end
