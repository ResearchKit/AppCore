// 
//  APCMedTrackerPrescription+Helper.m 
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
 
#import "APCMedTrackerPrescription+Helper.h"
#import "APCMedTrackerMedication.h"
#import "NSManagedObject+APCHelper.h"
#import "APCAppDelegate.h"
#import "APCDataSubstrate+CoreData.h"
#import "NSManagedObject+APCHelper.h"
#import "NSDate+Helper.h"
#import "APCMedTrackerDataStorageManager.h"
#import "APCMedTrackerPossibleDosage+Helper.h"
#import "APCMedTrackerMedication+Helper.h"
#import "APCMedTrackerPrescriptionColor+Helper.h"
#import "APCMedTrackerDailyDosageRecord+Helper.h"


/*
 Note to reviewers:
 
 - there are various hard-coded "errorDomains" and "errorCodes"
 throughout this file.  Acknowledged.  We're working toward a
 centralized way to manage those.
 
 - similarly, there's a utility method that creates an NSError
 object from a domain, a code, and a root-cause error.  We'll
 shortly move that to another class, too.
 */


static NSString * const kSeparatorForZeroBasedDaysOfTheWeek = @",";


@implementation APCMedTrackerPrescription (Helper)



// ---------------------------------------------------------
#pragma mark - Fetching and creating Prescriptions
// ---------------------------------------------------------

+ (void) newPrescriptionWithMedication: (APCMedTrackerMedication *) medicine
                                dosage: (APCMedTrackerPossibleDosage *) dosage
                                 color: (APCMedTrackerPrescriptionColor *) color
                      frequencyAndDays: (NSDictionary *) frequencyAndDays
                       andUseThisQueue: (NSOperationQueue *) someQueue
                      toDoThisWhenDone: (APCMedTrackerObjectCreationCallbackBlock) callbackBlock
{
    NSNumber *numberOfTimesPerDay = nil;
    NSMutableArray *zeroBasedDaysOfTheWeek = [NSMutableArray new];

    // Find the number of times per day:  the first non-zero entry.
    // By definition, all days have the same number of times per day.
    for (id thingy in frequencyAndDays.allValues)
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
    for (NSString *key in frequencyAndDays.allKeys)
    {
        id value = frequencyAndDays [key];

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
    [self newPrescriptionWithMedication: medicine
                                 dosage: dosage
                                  color: color
                          daysOfTheWeek: zeroBasedDaysOfTheWeek
                    numberOfTimesPerDay: numberOfTimesPerDay
                        andUseThisQueue: someQueue
                       toDoThisWhenDone: callbackBlock];
}

+ (void) newPrescriptionWithMedication: (APCMedTrackerMedication *) medicine
                                dosage: (APCMedTrackerPossibleDosage *) dosage
                                 color: (APCMedTrackerPrescriptionColor *) color
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

            APCMedTrackerPrescription *prescription = [APCMedTrackerPrescription newObjectForContext: localContext];

            prescription.medication = medicine;
            prescription.dosage = dosage;
            prescription.color = color;
            prescription.zeroBasedDaysOfTheWeek = [zeroBasedDaysOfTheWeek componentsJoinedByString: kSeparatorForZeroBasedDaysOfTheWeek];
            prescription.numberOfTimesPerDay = numberOfTimesPerDay;
            prescription.dateStartedUsing = [NSDate date];

            NSError *error = nil;
            BOOL itWorked = [prescription saveToPersistentStore: &error];

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
                callbackBlock (prescription, operationDuration);
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



// ---------------------------------------------------------
#pragma mark - Fetching and saving DailyDosageRecords
// ---------------------------------------------------------

/**
 This method does create, update, and/or delete, as needed.
 See comments in the header file for details.
 */
- (void) recordThisManyDoses: (NSUInteger) numberOfDosesTaken
                 takenOnDate: (NSDate *) endUsersChosenDate
             andUseThisQueue: (NSOperationQueue *) someQueue
            toDoThisWhenDone: (APCMedTrackerRecordDosesCallback) callbackBlock
{
    __block APCMedTrackerPrescription *blockSafePrescription = self;

    [APCMedTrackerDataStorageManager.defaultManager.queue addOperationWithBlock:^{

        NSDate *startTime = [NSDate date];
        NSManagedObjectContext *context = APCMedTrackerDataStorageManager.defaultManager.context;

        // We can also use -performBlockAndWait:.
        [context performBlock: ^{

            //
            // Delete any existing record(s) for today which are (ahem)
            // ACTUALLY ASSOCIATED WITH THIS PRESCRIPTION.  (This didn't
            // cause us last-minute problems, or anything...)
            //
            
            NSString *dateFieldName = NSStringFromSelector (@selector (dateThisRecordRepresents));
            
            NSPredicate *dateFilter = [NSPredicate predicateWithFormat: @"%K >= %@ AND %K <= %@",
                                       dateFieldName,
                                       endUsersChosenDate.startOfDay,
                                       dateFieldName,
                                       endUsersChosenDate.endOfDay];
            
            NSSet *filteredRecords = [blockSafePrescription.actualDosesTaken filteredSetUsingPredicate: dateFilter];
            
            // We're about to delete ALL dosage records attached to this
            // prescription.  If we HAPPEN to ALSO be creating a record,
            // then when we save that record, the deleted guys will actually
            // get deleted.  However, if we DON'T happen to create a record,
            // we need to call "save:" on SOMEthing.  So let's keep hold
            // of one of the records we're about to delete so we can "save" it.
            APCMedTrackerDailyDosageRecord *anyObjectBeingDeleted = filteredRecords.anyObject;
            
            // Now:  actually delete the records.  When we call "save" on
            // anything, we actually save the context, which will do the
            // real "delete" operation.
            for (APCMedTrackerDailyDosageRecord *oldRecord in filteredRecords)
            {
                [context deleteObject: oldRecord];
            }
            
            
            //
            // Create a new record, if appropriate.
            //
            
            APCMedTrackerDailyDosageRecord *dosageRecordWereCreating = nil;

            if (numberOfDosesTaken > 0)
            {
                dosageRecordWereCreating = [APCMedTrackerDailyDosageRecord newObjectForContext: context];
                dosageRecordWereCreating.prescriptionIAmBasedOn = blockSafePrescription;
                dosageRecordWereCreating.dateThisRecordRepresents = endUsersChosenDate;
                dosageRecordWereCreating.numberOfDosesTakenForThisDate = @(numberOfDosesTaken);
            }


            //
            // Save.  This saves the whole Context, which therefore
            // - saves the Presription object
            // - saves the new Dosage record, if it exists
            // - deletes any old Dosage records, if they exist
            //
            // We have to save SOMEthing, but it doesn't matter which object
            // we save.
            //
            
            BOOL successfullySaved = NO;
            NSError *coreDataError = nil;
           
            if (dosageRecordWereCreating)
            {
                successfullySaved = [dosageRecordWereCreating saveToPersistentStore: & coreDataError];
            }
            else if (anyObjectBeingDeleted)
            {
                successfullySaved = [anyObjectBeingDeleted saveToPersistentStore: & coreDataError];
            }
            else
            {
                // We have nothing to save and nothing to delete.  Theoretically,
                // we can't get here.  Ahem.  :-)  Let's see what happens.
            }
            
                
            NSLog(@"###### Setting number of records for prescription [%@] on date [%@] to: [%@]. ######", blockSafePrescription, endUsersChosenDate, @(numberOfDosesTaken));


            NSString *errorDomainToReturn = nil;
            NSInteger errorCode = 0;

            if (successfullySaved)
            {
                // Nothing to do.  Yay!
            }
            else
            {
                errorDomainToReturn = @"MedTrackerDataStorageError_CantSaveOrDeleteDosageRecord";
                errorCode = 2;

                // if the coreDataError is set, we'll use it in a moment.
            }


            //
            // Report.
            //

            NSTimeInterval operationDuration = [[NSDate date] timeIntervalSinceDate: startTime];

            if (someQueue != nil && callbackBlock != NULL)
            {
                NSError *errorToReturn = [self errorWithDomain: errorDomainToReturn
                                                          code: errorCode
                                               underlyingError: coreDataError];

                [someQueue addOperationWithBlock: ^{
                    callbackBlock (operationDuration, errorToReturn);
                }];
            }
        }];
    }];
}

- (void) fetchDosesTakenFromDate: (NSDate *) startDate
                          toDate: (NSDate *) endDate
                 andUseThisQueue: (NSOperationQueue *) someQueue
                toDoThisWhenDone: (APCMedTrackerFetchDosesCallback) callbackBlock
{
    __block APCMedTrackerPrescription *blockSafeSelf = self;
    
    [APCMedTrackerDataStorageManager.defaultManager.queue addOperationWithBlock:^{

        NSDate *startTime = [NSDate date];
        
//        NSManagedObjectContext *context = APCMedTrackerDataStorageManager.defaultManager.context;
//
//        // Gradually working toward normalizing our error-handling.
//        NSError *coreDataError = nil;
//        NSString *errorDomain = nil;
//        NSInteger errorCode = 0;
//
//        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName: NSStringFromClass ([APCMedTrackerDailyDosageRecord class])];
//
//        NSString *nameOfDateGetterMethod = NSStringFromSelector (@selector (dateThisRecordRepresents));
//
//        request.predicate = [NSPredicate predicateWithFormat:
//                             @"%K >= %@ && %K <= %@",
//                             nameOfDateGetterMethod,
//                             startDate.startOfDay,
//                             nameOfDateGetterMethod,
//                             endDate.endOfDay];
//
//        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey: nameOfDateGetterMethod
//                                                                  ascending: YES]];
//
//        // "nil" means "a CoreData error occurred."  That's our default value.
//        NSArray *dailyRecordsFound = [context executeFetchRequest: request error: & coreDataError];
//
//        if (dailyRecordsFound == nil)
//        {
//            errorDomain = @"MedTrackerDataStorageError";
//            errorCode = 1;
//
//            // We'll return the error CoreData sent us as an underlyingError, shortly.
//        }
//        else
//        {
//            // Done!
//        }
        
        
        NSError    *coreDataError = nil;
        NSString   *errorDomain = nil;
        NSInteger  errorCode = 0;
        
        NSString *dateFieldName = NSStringFromSelector (@selector (dateThisRecordRepresents));
        
        NSPredicate *dateFilter = [NSPredicate predicateWithFormat: @"%K >= %@ AND %K <= %@",
                                   dateFieldName,
                                   startDate.startOfDay,
                                   dateFieldName,
                                   endDate.endOfDay];
        
        NSSet *filteredRecords = [self.actualDosesTaken filteredSetUsingPredicate: dateFilter];
        NSArray *dailyRecordsFound = [filteredRecords allObjects];

        NSTimeInterval operationDuration = [[NSDate date] timeIntervalSinceDate: startTime];

        if (someQueue != nil && callbackBlock != NULL)
        {
            NSError *error = [self errorWithDomain: errorDomain
                                              code: errorCode
                                   underlyingError: coreDataError];

            [someQueue addOperationWithBlock: ^{
                callbackBlock (blockSafeSelf, dailyRecordsFound, operationDuration, error);
            }];
        }
    }];
}



// ---------------------------------------------------------
#pragma mark - Disabling ("expiring") the Prescription
// ---------------------------------------------------------

- (void) expirePrescriptionAndUseThisQueue: (NSOperationQueue *) someQueue
                          toDoThisWhenDone: (APCMedTrackerExpirePresriptionCallback) callbackBlock
{
    __block APCMedTrackerPrescription *blockSafePrescription = self;
    
    [APCMedTrackerDataStorageManager.defaultManager.queue addOperationWithBlock:^{
        
        NSDate *startTime = [NSDate date];
        NSManagedObjectContext *context = APCMedTrackerDataStorageManager.defaultManager.context;
        
        // We can also use -performBlockAndWait:.
        [context performBlock: ^{
            
            NSString *errorDomainToReturn = nil;
            NSInteger errorCode = 0;
            NSError *coreDataError = nil;

            //
            // All this overhead (ahem:  "noise") for the following
            // nearly-trivial operation:
            //
            // Note:  there's also a -didStopUsingOnDoctorsOrders
            // field.  I overengineered that.  Ahem.  We don't need it.
            // We're purposely ignoring it.
            //
            blockSafePrescription.dateStoppedUsing = [NSDate date];
            
            //
            // Save it.
            //
            BOOL successfullySaved = [blockSafePrescription saveToPersistentStore: & coreDataError];
            
            if (successfullySaved)
            {
                    // Nothing to do.  Yay!
            }
            else
            {
                errorDomainToReturn = @"MedTrackerDataStorageError_CantExpirePrescription";
                errorCode = 3;
                
                // if the coreDataError is set, we'll use it in a moment.
            }
            
            NSTimeInterval operationDuration = [[NSDate date] timeIntervalSinceDate: startTime];
            
            if (someQueue != nil && callbackBlock != NULL)
            {
                NSError *errorToReturn = [self errorWithDomain: errorDomainToReturn
                                                          code: errorCode
                                               underlyingError: coreDataError];
                
                [someQueue addOperationWithBlock: ^{
                    callbackBlock (operationDuration, errorToReturn);
                }];
            }
        }];
    }];
}



// ---------------------------------------------------------
#pragma mark - Computed properties
// ---------------------------------------------------------

- (BOOL) isActive
{
    BOOL result = YES;

    if (self.dateStoppedUsing != nil && self.dateStoppedUsing.isInThePast)
    {
        result = NO;
    }

    return result;
}

- (NSArray *) zeroBasedDaysOfTheWeekAsArrayOfSortedNumbers
{
    NSArray *strings = [self.zeroBasedDaysOfTheWeek componentsSeparatedByString: kSeparatorForZeroBasedDaysOfTheWeek];

    NSMutableArray *numbers = [NSMutableArray new];

    for (NSString *dayNumberString in strings)
    {
        [numbers addObject: @(dayNumberString.integerValue)];
    }

    [numbers sortUsingSelector: @selector(compare:)];

    return numbers;
}

- (NSDictionary *) frequencyAndDays
{
    NSMutableDictionary *result = [NSMutableDictionary new];
    NSArray *zeroBasedDaysArray = self.zeroBasedDaysOfTheWeekAsArrayOfSortedNumbers;

    for (NSUInteger zeroBasedDayOfWeek = 0; zeroBasedDayOfWeek < 7; zeroBasedDayOfWeek ++)
    {
        NSNumber *dayNumber = @(zeroBasedDayOfWeek);
        NSNumber *pillsToTakeOnThatDay = @(0);

        if ([zeroBasedDaysArray containsObject: dayNumber])
        {
            pillsToTakeOnThatDay = self.numberOfTimesPerDay;
        }

        NSString *dayNameName = [[self class] nameForZeroBasedDay: dayNumber];
        result [dayNameName] = pillsToTakeOnThatDay;
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



// ---------------------------------------------------------
#pragma mark - Utilities
// ---------------------------------------------------------

/**
 Working toward normalizing my error-handling.
 If you provide a nil or empty domain string, this
 method returns nil.  Otherwise, creates an error
 with the specified domain and code.  If underlyingError
 is not nil, attaches it to a userInfo dictionary with
 the appropriate Apple key.
 */
- (NSError *) errorWithDomain: (NSString *) domain
                         code: (NSInteger) code
              underlyingError: (NSError *) underlyingError
{
    NSError *error = nil;

    if (domain.length > 0)
    {
        NSDictionary *userInfoDictionary = nil;

        if (underlyingError != nil)
        {
            userInfoDictionary = @{ NSUnderlyingErrorKey: underlyingError };
        }

        error = [NSError errorWithDomain: domain
                                    code: code
                                userInfo: userInfoDictionary];
    }
    
    return error;
}



// ---------------------------------------------------------
#pragma mark - Description method
// ---------------------------------------------------------

- (NSString *) description
{
    /*
     Convert from a string like "4,1" to "Monday, Thursday":
     - original: "4,1"
     - split: "4", "1"
     - numbers:  4, 1
     - sort: 1, 4
     - names: "Monday", "Thursday"
     - unified string: "Monday, Thursday"
     */
    NSArray *zeroBasedDaysOfTheWeekArray = self.zeroBasedDaysOfTheWeekAsArrayOfSortedNumbers;
    NSMutableArray *dayNames = [NSMutableArray new];
    for (NSNumber *dayNumber in zeroBasedDaysOfTheWeekArray)
    {
        NSString *dayName = [[self class] nameForZeroBasedDay: dayNumber];
        [dayNames addObject: dayName];
    }

    NSString *result = [NSString stringWithFormat: @"Prescription { medication: %@, days: (%@), timesPerDay: %@, dosage: %@, color: %@, isActive: %@ }",
                        self.self.medication.name,
                        [dayNames componentsJoinedByString: @", "],
                        self.numberOfTimesPerDay,
                        self.dosage.name,
                        self.color.name,
                        self.isActive ? @"YES" : @"NO"
                        ];

    return result;
}


@end
