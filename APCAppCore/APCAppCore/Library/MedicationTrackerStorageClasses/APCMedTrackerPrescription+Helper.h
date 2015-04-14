// 
//  APCMedTrackerPrescription+Helper.h 
//  APCAppCore 
// 
// Copyright (c) 2015, Apple Inc. All rights reserved. 
// 
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
// 
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
// 
// 2.  Redistributions in binary form must reproduce the above copyright notice, 
// this list of conditions and the following disclaimer in the documentation and/or 
// other materials provided with the distribution. 
// 
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors 
// may be used to endorse or promote products derived from this software without 
// specific prior written permission. No license is granted to the trademarks of 
// the copyright holders even if such marks are included in this software. 
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE 
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
// 
 
#import "APCMedTrackerPrescription.h"
@class APCMedTrackerMedication;
@class APCMedTrackerPossibleDosage;
@class APCMedTrackerPrescriptionColor;


// ---------------------------------------------------------
#pragma mark - Block Typedefs
// ---------------------------------------------------------

/*
 Various blocks used by the methods in this class.
 */

/**
 Some mightily useful documentation for this
 particular callback.  ...ahem.  (Getting there...)
 */
typedef void (^APCMedTrackerObjectCreationCallbackBlock) (id createdObject,
                                                          NSTimeInterval operationDuration);

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

/**
 The -fetchDosesTaken...: method calls a block with
 this signature when it completes.
 */
typedef void (^ APCMedTrackerRecordDosesCallback) (NSTimeInterval operationDuration,
                                                   NSError *error);

/**
 The -fetchDosesTaken...: method calls a block with
 this signature when it completes.
 */
typedef void (^ APCMedTrackerFetchDosesCallback) (APCMedTrackerPrescription *prescription,
                                                  NSArray *dailyDosageRecords,
                                                  NSTimeInterval operationDuration,
                                                  NSError *error);

/**
 The -expirePrescxription...: method calls a block with
 this signature when it completes.
 */
typedef void (^ APCMedTrackerExpirePresriptionCallback) (NSTimeInterval operationDuration,
                                                         NSError *error);


// ---------------------------------------------------------
#pragma mark - The Class Itself
// ---------------------------------------------------------

@interface APCMedTrackerPrescription (Helper)

+ (void) newPrescriptionWithMedication: (APCMedTrackerMedication *) medicine
                                dosage: (APCMedTrackerPossibleDosage *) dosage
                                 color: (APCMedTrackerPrescriptionColor *) color
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

 + (void) newPrescriptionWithMedication: (APCMedTrackerMedication *) medicine
                                 dosage: (APCMedTrackerPossibleDosage *) dosage
                                  color: (APCMedTrackerPrescriptionColor *) color
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
 Records the specified number of doses taken for this
 prescription on the specified date.  Use 0 for
 numberOfDosesTaken to clear that data (e.g., if the
 user decided they tapped the wrong button).
 
 This method does create, update, and/or delete, as needed:
 -  If this is the first time something is being recorded
    for the specified date, we'll create a new record.

 -  If the user is updating the number of doses taken
    for a given date, we'll find the previous record
    and update it.

 -  If the user is setting the number of doses for this
    date back to zero (like, "oh, I meant to choose Wednesday,
    not Monday" or "Darnit! I was just trying to see what
    this screen did, not update my records!"), we'll delete
    the existing record if it's there.
 */
- (void) recordThisManyDoses: (NSUInteger) numberOfDosesTaken
                 takenOnDate: (NSDate *) date
             andUseThisQueue: (NSOperationQueue *) someQueue
            toDoThisWhenDone: (APCMedTrackerRecordDosesCallback) callbackBlock;

/**
 Retrieves all doses taken for this schedule
 between the startDate and the endDate, inclusive.
 Returns a dictionary containing all such dates.
 The callbackBlock contains these parameters:
 
 -  (NSDictionary *datesAndDoses):  a dictionary
    mapping dates to the number of doses taken on
    that date:
 
        { date1 : doseCountOnDate1 ,
          date2 : doseCountOnDate2 ,
          ...
        }
 
    This dictionary will be nil if there was an error
    (in which case, check the "error" parameter).
    It will be empty if there were no doses taken
    for this prescription during that date range.
 
 -  (NSTimeInterval operationDuration):  How long the fetch
    operation took, in fractional seconds.
 
 -  (NSError *error):  if a problem happened, this will
    contain a valid NSError object.  If we got an error
    report from CoreData, we'll pass that to you.  Otherwise,
    will create an appropriate-sounding error.
 */
- (void) fetchDosesTakenFromDate: (NSDate *) startDate
                          toDate: (NSDate *) endDate
                 andUseThisQueue: (NSOperationQueue *) someQueue
                toDoThisWhenDone: (APCMedTrackerFetchDosesCallback) callbackBlock;


/**
 Sets the -dateStoppedUsing field to "now".
 */
- (void) expirePrescriptionAndUseThisQueue: (NSOperationQueue *) someQueue
                          toDoThisWhenDone: (APCMedTrackerExpirePresriptionCallback) callbackBlock;

/**
 Returns YES if the prescription is currently active:
 if its dateStoppedUsing field is nil.  Returns NO
 if dateStoppedUsing is non-nil and earlier than
 "now."  This means the default is YES.
 */
@property (readonly) BOOL isActive;

@property (readonly) NSDictionary *frequencyAndDays;
@property (readonly) NSArray *zeroBasedDaysOfTheWeekAsArrayOfSortedNumbers;
@property (readonly) NSArray *zeroBasedDaysOfTheWeekAsArrayOfSortedShortNames;

+ (NSString *) nameForZeroBasedDay: (NSNumber *) zeroBasedDayOfTheWeek;
+ (NSNumber *) zeroBasedDayOfTheWeekForDayName: (NSString *) dayName;

@end
