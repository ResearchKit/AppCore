//
//  APCDataMigrationPolicy_Model4ToModel6.m
//  APCAppCore
//
//  Copyright (c) 2015, Apple Inc. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification,
//  are permitted provided that the following conditions are met:
//
//  1.  Redistributions of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer.
//
//  2.  Redistributions in binary form must reproduce the above copyright notice,
//  this list of conditions and the following disclaimer in the documentation and/or
//  other materials provided with the distribution.
//
//  3.  Neither the name of the copyright holder(s) nor the names of any contributors
//  may be used to endorse or promote products derived from this software without
//  specific prior written permission. No license is granted to the trademarks of
//  the copyright holders even if such marks are included in this software.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
//  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
//  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
//  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
//  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
//  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "APCDataMigrationPolicy_Model4ToModel6.h"

#import "APCAppDelegate.h"
#import "APCConstants.h"
#import "APCDataMigrationMetadata_Model4ToModel6.h"
#import "APCDataSubstrate.h"
#import "APCLog.h"
#import "APCSchedule+AddOn.h"
#import "APCScheduleDebugPrinter.h"
#import "APCScheduledTask+AddOn.h"
#import "APCStoredUserData.h"
#import "APCTask+AddOn.h"
#import "APCUser.h"
#import "APCUtilities.h"
#import "NSDate+Helper.h"
#import "NSManagedObject+APCHelper.h"
#import "NSError+APCAdditions.h"


static NSString * const kAPCTaskIdPrefixGlucoseLog = @"APHLogGlucose";
static NSString * const kAPCDataMigrationMetadataKey = @"kAPCDataMigrationContextKey";

typedef enum : NSUInteger {
    kAPCErrorFetchingSchedulesWithNilStartDatesCode,
    kAPCErrorFetchingUsersCode,
}   kAPCError;

static NSString * const kAPCErrorDomain = @"APCDataMigrationError";
static NSString * const kAPCErrorFetchingSchedulesWithNilStartDatesReason = @"Unable to Fetch Schedules";
static NSString * const kAPCErrorFetchingSchedulesWithNilStartDatesSuggestion = @"Unable to fetch schedules with nil start dates during migration. You may wish to make sure the migration is happening correctly.";
static NSString * const kAPCErrorFetchingUsersReason = @"Unable to Fetch Users";
static NSString * const kAPCErrorFetchingUsersSuggestion = @"Unable to fetch users during migration. This doesn't mean there are no users in the database; it means we can't tell. You may wish to make sure the migration is happening correctly.";



@implementation APCDataMigrationPolicy_Model4ToModel6



// ---------------------------------------------------------
#pragma mark - Migration methods called from the model file
// ---------------------------------------------------------

/*
 All methods in this section are called by the migration
 process, because we typed these method names and
 parameters into the migration-model XML file
 (APCMappingModel4ToModel6.xcmappingmodel).  For details
 on how to do that, see the README file
 MODEL_MIGRATION_README.txt.
 */

- (NSNumber *) generateNewScheduleSourceFromOldSchedule: (id) scheduleFromV4
{
    NSNumber *result = [self extractScheduleSourceEnumValueFromOldSchedule: scheduleFromV4];

    return result;
}

/**
 Takes an old Schedule object, extracts its task ID,
 and converts that to a bunch of actual Tasks which we
 can then relate to the matching Schedule object in 
 the new model.
 */
- (NSSet *) linkTasksToV6ScheduleMatchingV4Schedule: (id) scheduleFromV4
                              usingMigrationManager: (NSMigrationManager *) manager
{
    NSSet *tasksWithCorrectId = nil;
    NSManagedObjectContext *context = manager.destinationContext;
    NSString *taskIdV4 = [self extractOriginalTaskIdFieldFromScheduleV4: scheduleFromV4];

    if (taskIdV4.length)
    {
        NSString *taskIdV6      = [self generateNewTaskIdFromOldTaskId: taskIdV4];
        NSNumber *taskVersionV6 = [self generateNewTaskVersionNumberFromOldTaskId: taskIdV4];

        NSError *errorFetchingTasks = nil;
        NSFetchRequest *request = [APCTask requestWithPredicate: [NSPredicate predicateWithFormat: @"%K == %@ && %K == %@",
                                                                  NSStringFromSelector (@selector (taskID)),
                                                                  taskIdV6,
                                                                  NSStringFromSelector (@selector (taskVersionNumber)),
                                                                  taskVersionV6]];

        NSArray *tasks = [context executeFetchRequest: request
                                                error: & errorFetchingTasks];

        if (! tasks)
        {
            // We don't really care about the error, but
            // for debugging this migration process.
            APCLogError2 (errorFetchingTasks);
        }
        else
        {
            tasksWithCorrectId = [NSSet setWithArray: tasks];
        }
    }

    return tasksWithCorrectId;
}

- (NSString *) generateNewTaskIdFromOldTaskId: (id) maybeTaskIdFromTaskV4
{
    NSString *taskIdForV6 = [self extractSageStyleTaskIdFromV4TaskId: maybeTaskIdFromTaskV4];

    /*
     Only the tasks from the server had that format.
     If we couldn't extract it, just use whatever we had.
     */
    if (taskIdForV6 == nil)
    {
        taskIdForV6 = maybeTaskIdFromTaskV4;
    }

    return taskIdForV6;
}

- (NSNumber *) generateNewTaskVersionNumberFromOldTaskId: (id) maybeTaskIdFromTaskV4
{
    // May be nil.  No problem.
    NSNumber *versionNumber = [self extractSageVersionNumberFromV4TaskId: maybeTaskIdFromTaskV4];

    return versionNumber;
}

/**
 Version 6 of the model introduces a maxCount field in the Schedule object,
 with a default value of 0.  We later decided the default should be nil
 unless explicitly set.  This method lets us fix the default value for
 schedules migrated from v4 to v6.  New schedules get their values set
 properly at creation time.

 @param scheduleFromV6  The "destination" schedule object:  the object created
 after the migration process has been performed on a schedule from version 4.
 For inspection during debugging.
 */
- (NSNumber *) repairImproperDefaultMaxCountInNewSchedule: (APCSchedule *) __unused scheduleFromV6
{
    return nil;
}



// ---------------------------------------------------------
#pragma mark - Cleanup, validation, other lifecycle methods
// ---------------------------------------------------------

/*
 These are (some of) the lifecycle methods for the Policy
 class.  Look at the documentation for these methods for
 details, as well as the discussion of CoreData's "three-
 stage migration":

 https://developer.apple.com/library/prerelease/ios/documentation/Cocoa/Conceptual/CoreDataVersioning/Articles/vmMigrationProcess.html
 */

- (BOOL) endRelationshipCreationForEntityMapping: (NSEntityMapping *) mapping
                                         manager: (NSMigrationManager *) manager
                                           error: (NSError * __autoreleasing *) __unused error
{
    BOOL result = YES;
    APCDataMigrationMetadata_Model4ToModel6 *metadata = [self metadataForManager: manager];

    if      ([mapping.name hasPrefix: NSStringFromClass ([APCStoredUserData class])]) { metadata.haveMigratedUserDataYet = YES; }
    else if ([mapping.name hasPrefix: NSStringFromClass ([APCSchedule       class])]) { metadata.haveMigratedScheduleDataYet = YES; }
    else if ([mapping.name hasPrefix: NSStringFromClass ([APCScheduledTask  class])]) { metadata.haveMigratedScheduledTaskRelationshipsYet = YES; }
    else if ([mapping.name hasPrefix: NSStringFromClass ([APCTask           class])]) { metadata.haveMigratedTaskRelationshipsYet = YES; }
    else if ([mapping.name hasPrefix: NSStringFromClass ([APCSchedule       class])]) { metadata.haveMigratedScheduleRelationshipsYet = YES; }

    if (metadata.haveMigratedUserDataYet && metadata.haveMigratedScheduleDataYet)
    {
        [self generateStartDatesForSchedulesWithNilStartDatesUsingManager: manager];
    }
    else if (metadata.haveMigratedScheduleRelationshipsYet &&
             metadata.haveMigratedTaskRelationshipsYet &&
             metadata.haveMigratedScheduledTaskRelationshipsYet)
    {
        // For now, just breaking here so I can inspect the results.
        [self printMigrationStatusUsingMigrationManager: manager];
    }

    return result;
}



// ---------------------------------------------------------
#pragma mark - Migration methods called from the lifecyle methods
// ---------------------------------------------------------

- (APCDataMigrationMetadata_Model4ToModel6 *) metadataForManager: (NSMigrationManager *) manager
{
    APCDataMigrationMetadata_Model4ToModel6 *metadata = manager.userInfo [kAPCDataMigrationMetadataKey];

    if (metadata == nil)
    {
        metadata = [APCDataMigrationMetadata_Model4ToModel6 new];
        manager.userInfo = @{ kAPCDataMigrationMetadataKey : metadata };
    }

    return metadata;
}

- (void) generateStartDatesForSchedulesWithNilStartDatesUsingManager: (NSMigrationManager *) manager
{
    NSManagedObjectContext *context = manager.destinationContext;
    NSError *errorFetchingSchedules = nil;

    NSPredicate *nilStartDates = [NSPredicate predicateWithFormat: @"%K == %@",
                                   NSStringFromSelector(@selector(startsOn)),
                                   nil];

    NSFetchRequest *requestNilStartDates = [APCSchedule requestWithPredicate: nilStartDates];

    NSArray *schedulesWithNilStartDates = [context executeFetchRequest: requestNilStartDates
                                                                 error: & errorFetchingSchedules];

    if (! schedulesWithNilStartDates)
    {
        // Error.  Should literally never happen if the
        // rest of this migration has been progressing
        // at all -- we shouldn't have gotten here.
        NSError *couldntQueryForSchedulesWithNilStartDates = [NSError errorWithCode: kAPCErrorFetchingSchedulesWithNilStartDatesCode
                                                                             domain: kAPCErrorDomain
                                                                      failureReason: kAPCErrorFetchingSchedulesWithNilStartDatesReason
                                                                 recoverySuggestion: kAPCErrorFetchingSchedulesWithNilStartDatesSuggestion
                                                                        nestedError: errorFetchingSchedules];

        APCLogError2 (couldntQueryForSchedulesWithNilStartDates);
    }
    else if (schedulesWithNilStartDates.count == 0)
    {
        // Nothing to worry about.
    }
    else  // have schedules with nil start dates.
    {
        APCScheduleDebugPrinter *printer = [APCScheduleDebugPrinter new];
        NSMutableString *printout = [NSMutableString new];

        [printer printArrayOfSchedules: schedulesWithNilStartDates
                             withLabel: @"\n\n During migration. About to fill these schedules with start dates"
                     intoMutableString: printout];
        
        NSDate *consentSignatureDate = nil;
        NSError *errorFetchingUsers = nil;
        NSFetchRequest *requestAllUsers = [APCStoredUserData request];
        NSArray *users = [context executeFetchRequest: requestAllUsers error: & errorFetchingUsers];

        if (! users)
        {
            // Error.  Should literally never happen if the
            // rest of this migration has been progressing
            // at all -- we shouldn't have gotten here.
            NSError *couldntQueryForUsers = [NSError errorWithCode: kAPCErrorFetchingUsersCode
                                                            domain: kAPCErrorDomain
                                                     failureReason: kAPCErrorFetchingUsersReason
                                                recoverySuggestion: kAPCErrorFetchingUsersSuggestion
                                                       nestedError: errorFetchingSchedules];

            APCLogError2 (couldntQueryForUsers);
        }
        else if (users.count == 0)
        {
            // Hm.  Shouldn't happen, but we can deal with it (below).
        }
        else
        {
            // There should truly never be more than one user, as of the date
            // of this migration -- that's not how our code works.
            APCStoredUserData *user = users.firstObject;
            consentSignatureDate = user.consentSignatureDate;
        }

        if (consentSignatureDate == nil)
        {
            // Same logic as in -[APCUser estimatedConsentDate]:
            // if we can't get the user's consent date, try a
            // series of best guesses, ending with today's date.
            consentSignatureDate = [APCUser proxyForConsentDate];

            // Should truly never happen, but:
            if (consentSignatureDate == nil)
            {
                consentSignatureDate = [NSDate date];
            }
        }

        for (APCSchedule *schedule in schedulesWithNilStartDates)
        {
            if (schedule.startsOn == nil)
            {
                /*
                 The effectiveStartDate is startsOn + delay,
                 but migrated schedules don't have delays.
                 (We're migrating to a data model that
                 gives us delays.)
                 */
                schedule.startsOn = consentSignatureDate;
                schedule.effectiveStartDate = consentSignatureDate.startOfDay;
            }
            else
            {
                /*
                 Should never happen.  Prevented by the fetchRequest at
                 the top of this method.  (This "else" clause serves to
                 ensure that we don't destroy existing start dates;
                 ending up here is not a problem.)
                 */
            }
        }

        [printer printArrayOfSchedules: schedulesWithNilStartDates
                             withLabel: @"Here's what we did"
                     intoMutableString: printout];

        APCLogDebug (@"%@", printout);
    }
}



// ---------------------------------------------------------
#pragma mark - Utilities
// ---------------------------------------------------------

/*
 The methods in this section are called by the 
 migration-mapping methods above.
 */

- (NSString *) extractOriginalTaskIdFieldFromScheduleV4: (id) scheduleFromV4
{
    NSString *result = nil;

    if ([scheduleFromV4 respondsToSelector: @selector (taskID)])
    {
        id maybeTaskId = [scheduleFromV4 taskID];

        if (maybeTaskId != nil && [maybeTaskId isKindOfClass: [NSString class]])
        {
            result = maybeTaskId;
        }
    }

    return result;
}

/**
 Our old "taskID"s were a mash of the original Sage task ID,
 a date, and version number if it was available.  We ignore
 the date, and use the task ID and version number directly.
 
 Compare with -extractSageVersionNumberFromV4TaskId:.
 This method extracts the leading "id" part; that method
 extracts the trailing version-number part.

 Here was the original method that converted the ID, date,
 and version into a single string.  This is what we need
 to undo.  This method was in a category we'd written around
 a Sage-provided class, SBBGuidCreatedOnVersionHolder:

     - (NSString*) uniqueID
     {
         NSString * retValue;
         if (self.version != nil) {
             retValue = [NSString stringWithFormat:@"%@-%@-%@", self.guid, self.createdOn, self.version];
         }
         else if (self.versionValue > 0)
         {
             retValue = [NSString stringWithFormat:@"%@-%@-%lld", self.guid, self.createdOn, self.versionValue];
         }
         else
         {
             retValue = [NSString stringWithFormat:@"%@-%@", self.guid, self.createdOn];
         }
         return retValue;
     }
 */
- (NSString *) extractSageStyleTaskIdFromV4TaskId: (id) maybeTaskIdFromTaskV4
{
    NSString *taskIdForV6 = nil;

    if (maybeTaskIdFromTaskV4 != nil && [maybeTaskIdFromTaskV4 isKindOfClass: [NSString class]])
    {
        /*
         A regular expression to recognize task IDs.
         Sample format:  88e6db5b-0afa-499f-88e5-83465471be3d
         */
        NSString *uuidRegex = (@""
                               "[a-fA-F0-9]{8}\\-"      // 8 hex chars + literal hyphen
                               "[a-fA-F0-9]{4}\\-"      // 4 hex chars + literal hyphen
                               "[a-fA-F0-9]{4}\\-"      // 4 hex chars + literal hyphen
                               "[a-fA-F0-9]{4}\\-"      // 4 hex chars + literal hyphen
                               "[a-fA-F0-9]{12}");      // 12 hex chars

        NSString *taskIdFromV4 = maybeTaskIdFromTaskV4;

        NSRange uuidRange = [taskIdFromV4 rangeOfString: uuidRegex
                                                options: NSRegularExpressionSearch | NSCaseInsensitiveSearch];

        /*
         This is part of the analysis: the task ID has to
         be the first part of the string.
         */
        if (uuidRange.location == 0)
        {
            taskIdForV6 = [taskIdFromV4 substringWithRange: uuidRange];
        }
    }

    return taskIdForV6;
}

/**
 See comments on -extractSageStyleTaskIdFromV4TaskId:.
 That method extracts the leading "id" part; this method
 extracts the trailing version-number part.

 In practice, the version numbers were often nil, so
 this method will likely often return nil.
 */
- (NSNumber *) extractSageVersionNumberFromV4TaskId: (id) maybeTaskIdFromTaskV4
{
    NSNumber *versionNumber = nil;

    NSString *taskIdForV6 = [self extractSageStyleTaskIdFromV4TaskId: maybeTaskIdFromTaskV4];

    if (taskIdForV6 != nil)
    {
        NSString *taskIdFromV4 = maybeTaskIdFromTaskV4;
        NSString *stuffAfterStrippingTaskId = [taskIdFromV4 substringFromIndex: taskIdFromV4.length];
        NSString *regexForTrailingHyphenAndInteger = @"\\-\\d+$";
        NSRange versionNumberRange = [stuffAfterStrippingTaskId rangeOfString: regexForTrailingHyphenAndInteger
                                                                      options: NSRegularExpressionSearch];

        if (versionNumberRange.location != NSNotFound)
        {
            NSString *hyphenAndInteger = [stuffAfterStrippingTaskId substringFromIndex: versionNumberRange.location];
            NSString *theInteger = [hyphenAndInteger substringFromIndex: @"-".length];
            NSUInteger versionValue = theInteger.integerValue;
            versionNumber = @(versionValue);
        }
    }

    return versionNumber;
}

- (NSNumber *) extractScheduleSourceEnumValueFromOldSchedule: (id) scheduleFromV4
{
    NSNumber *result = nil;
    APCScheduleSource scheduleSource = APCScheduleSourceLocalDisk;

    /*
     This refers to the property -[APCSchedule remoteUpdatable]
     in the code we're migrating from.
     */
    id maybeRemoteUpdatable = [scheduleFromV4 valueForKey: @"remoteUpdatable"];

    if (maybeRemoteUpdatable != nil && [maybeRemoteUpdatable isKindOfClass: [NSNumber class]])
    {
        NSNumber *remoteUpdatable = maybeRemoteUpdatable;
        BOOL isRemoteUpdatable = remoteUpdatable.boolValue;
        scheduleSource = isRemoteUpdatable ? APCScheduleSourceServer : APCScheduleSourceLocalDisk;
    }
    else
    {
        scheduleSource = APCScheduleSourceLocalDisk;
    }

    /*
     If this is the singleton schedule managing the Glucose
     Log, set its Source to GlucoseLog.
     */
    NSString *taskId = [self extractOriginalTaskIdFieldFromScheduleV4: scheduleFromV4];

    if (taskId != nil && [taskId hasPrefix: kAPCTaskIdPrefixGlucoseLog])
    {
        scheduleSource = APCScheduleSourceGlucoseLog;
    }

    result = @(scheduleSource);
    return result;
}

- (void) printMigrationStatusUsingMigrationManager: (NSMigrationManager *) manager
{
    NSManagedObjectContext *context = manager.destinationContext;

    NSArray *schedules      = [context executeFetchRequest: [APCSchedule request]       error: nil];
    NSArray *tasks          = [context executeFetchRequest: [APCTask request]           error: nil];
    NSArray *completedItems = [context executeFetchRequest: [APCScheduledTask request]  error: nil];

    NSMutableString *printout = [NSMutableString stringWithFormat:
                                 @"\n\n========= Current state of the world: ==========\n\n"
                                 "-------------- Schedules --------------\n%@\n\n"
                                 "-------------- Tasks --------------\n%@\n\n"
                                 "-------------- Completed ScheduledTasks --------------\n%@",
                                 schedules,
                                 tasks,
                                 completedItems];

    [printout replaceOccurrencesOfString: @"\\n" withString: @"\n" options: 0 range: NSMakeRange (0, printout.length)];
    [printout replaceOccurrencesOfString: @"\\\"" withString: @"\"" options: 0 range: NSMakeRange (0, printout.length)];

    APCLogDebug (@"%@", printout);
    APCLogDebug (@"");      // easy place to put a breakpoint, in order to inspect the printout
}


@end
