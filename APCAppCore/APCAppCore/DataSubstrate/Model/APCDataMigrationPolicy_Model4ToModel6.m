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

- (void) printMigrationStatusUsingMigrationManager: (NSMigrationManager *) manager
{
    NSManagedObjectContext *context = manager.destinationContext;

    NSArray *tasks          = [context executeFetchRequest: [APCTask request]           error: nil];

    NSMutableString *printout = [NSMutableString stringWithFormat:
                                 @"\n\n========= Current state of the world: ==========\n\n"
                                 "-------------- Tasks --------------\n%@\n\n",
                                 tasks];

    [printout replaceOccurrencesOfString: @"\\n" withString: @"\n" options: 0 range: NSMakeRange (0, printout.length)];
    [printout replaceOccurrencesOfString: @"\\\"" withString: @"\"" options: 0 range: NSMakeRange (0, printout.length)];

    APCLogDebug (@"%@", printout);
    APCLogDebug (@"");      // easy place to put a breakpoint, in order to inspect the printout
}


@end
