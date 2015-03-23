// 
//  APCDataSubstrate+CoreData.m 
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
 
#import "APCDataSubstrate+CoreData.h"
#import "APCAppCore.h"
#import <CoreData/CoreData.h>


@implementation APCDataSubstrate (CoreData)

/*********************************************************************************/
#pragma mark - Core Data Subsystem
/*********************************************************************************/

- (void) setUpCoreDataStackWithPersistentStorePath: (NSString*) storePath additionalModels:(NSManagedObjectModel *)mergedModels
{
    [self loadManagedObjectModel:mergedModels];
    [self initializePersistentStoreCoordinator:storePath];
    [self createManagedObjectContexts];
}

- (void) loadManagedObjectModel: (NSManagedObjectModel*) mergedModels
{
    NSBundle* bundle =[NSBundle appleCoreBundle];
    
    NSString * modelPath = [bundle pathForResource:@"APCModel" ofType:@"momd"];
    NSAssert(modelPath, @"No Model Path Found!");
    NSURL *modelURL = [NSURL fileURLWithPath:modelPath];
    NSManagedObjectModel * model = [[[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL] mutableCopy];
    if (mergedModels) {
        model = [NSManagedObjectModel modelByMergingModels:@[model, mergedModels]];
    }
    self.managedObjectModel = model;
}

- (void) initializePersistentStoreCoordinator: (NSString*) storePath
{
    self.storePath = storePath;
    self.persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    [self setUpPersistentStore];
}

- (void) setUpPersistentStore
{
    NSError *error               = nil;
    NSURL   *persistentStoreUrl  = [NSURL fileURLWithPath: self.storePath];
    BOOL    fileAlreadyExists    = [[NSFileManager defaultManager] fileExistsAtPath: self.storePath];

    NSDictionary *options = @{ NSMigratePersistentStoresAutomaticallyOption : @(YES),
                               NSInferMappingModelAutomaticallyOption       : @(YES)
                               };

    NSPersistentStore *persistentStore = [self.persistentStoreCoordinator addPersistentStoreWithType: NSSQLiteStoreType
                                                                                       configuration: nil
                                                                                                 URL: persistentStoreUrl
                                                                                             options: options
                                                                                               error: & error];

    if (persistentStore)
    {
        // Great!  Everything worked.  (Sound of whistling)
    }

    else
    {
        /*
         In case we want to switch() on them, the list of possible
         CoreData errors is here:

                https://developer.apple.com/library/ios/documentation/Cocoa/Reference/CoreDataFramework/Miscellaneous/CoreData_Constants/
         */

        NSInteger errorCode = kAPCErrorDomain_CoreData_Code_Undetermined;

        NSMutableDictionary * userInfo = @{ NSUnderlyingErrorKey : error ?: [NSNull null],
                                            NSFilePathErrorKey   : self.storePath,
                                           }.mutableCopy;

        if (fileAlreadyExists)
        {
            errorCode = kAPCErrorDomain_CoreData_Code_CantOpenExistingDatabase;

            [userInfo addEntriesFromDictionary:
             @{
               NSLocalizedFailureReasonErrorKey: NSLocalizedString (@"Unable to Open Database",
                                                                    @"If we can't open the user's existing data file, they'll see an alert with this title."),

               NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString (@"Unable to open your existing data file. Please exit the app and try again. If the problem recurs, please uninstall and reinstall the app.",
                                                                         @"If we can't open the user's existing data file, they'll see an alert with this message."),
               }];
        }
        else
        {
            errorCode = kAPCErrorDomain_CoreData_Code_CantCreateDatabase;

            [userInfo addEntriesFromDictionary:
             @{
               NSLocalizedFailureReasonErrorKey: NSLocalizedString (@"Unable to Create Database",
                                                                    @"If we can't open create a place to store the user's data, they'll see an alert with this title."),

               NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString (@"We were unable to create a place to save your data. Please exit the app and try again. If the problem recurs, please uninstall the app and try once more.",
                                                                         @"If we can't open create a place to store the user's data, they'll see an alert with this message."),
               }];
        }

        NSError *catastrophe = [NSError errorWithDomain: kAPCErrorDomain_CoreData
                                                   code: errorCode
                                               userInfo: userInfo];

        APCLogError2 (catastrophe);


        /*
         Report this actually-catastrophic error to the app.
         It'll display it when it gets a chance -- a few
         milliseconds from now, asynchronously.
         */
        APCAppDelegate *appDelegate = (APCAppDelegate *) [[UIApplication sharedApplication] delegate];
        [appDelegate registerCatastrophicStartupError: catastrophe];
    }
}

- (void) removeSqliteStore
{
    NSError* localError;
    [[NSFileManager defaultManager] removeItemAtPath:self.storePath error:&localError];
    APCLogError2 (localError);
}

- (void) createManagedObjectContexts
{
    self.persistentContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    self.persistentContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
    
    self.mainContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    self.mainContext.parentContext = self.persistentContext;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mergeChangesToMainContext:) name:NSManagedObjectContextDidSaveNotification object:self.persistentContext];
}

- (void) mergeChangesToMainContext: (NSNotification*) notification
{
    [self.mainContext performBlock:^{
        [self.mainContext mergeChangesFromContextDidSaveNotification:notification];
    }];

}

/*********************************************************************************/
#pragma mark - Core Data Public Methods
/*********************************************************************************/
- (void)loadStaticTasksAndSchedules: (NSDictionary*) jsonDictionary
{
    [APCTask createTasksFromJSON:jsonDictionary[@"tasks"] inContext:self.persistentContext];
    [APCSchedule createSchedulesFromJSON:jsonDictionary[@"schedules"] inContext:self.persistentContext];
}

- (void)resetCoreData
{
    //EXERCISE CAUTION IN CALLING THIS METHOD
    [self.mainContext reset];
    [self.persistentContext reset];
    NSError * error;
    NSPersistentStore * persistenStore = [self.persistentStoreCoordinator persistentStores] [0];
    [self.persistentStoreCoordinator removePersistentStore:persistenStore error:&error];
    APCLogError2 (error);
    [self removeSqliteStore];
    [self setUpPersistentStore];
    APCAppDelegate * appDelegate = (APCAppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate loadStaticTasksAndSchedulesIfNecessary];
}

/*********************************************************************************/
#pragma mark - Helpers - ONLY RETURNS IN NSManagedObjects in mainContext
/*********************************************************************************/

- (NSFetchRequest*) requestForScheduledTasksDueFrom:(NSDate *)fromDate toDate:(NSDate *)toDate sortDescriptors: (NSArray*) sortDescriptors
{
    NSFetchRequest * request = [APCScheduledTask request];
    request.predicate = [NSPredicate predicateWithFormat:@"dueOn >= %@ and dueOn < %@", fromDate, toDate];
    request.sortDescriptors = sortDescriptors;
    return request;
}

- (NSArray *)scheduledTasksDueFrom:(NSDate *)fromDate toDate:(NSDate *)toDate sortDescriptors: (NSArray*) sortDescriptors
{
    NSError* error;
    return [self.mainContext executeFetchRequest:[self requestForScheduledTasksDueFrom:fromDate toDate:toDate sortDescriptors:sortDescriptors] error:&error];
}

- (NSFetchRequest*) requestForScheduledTasksForPredicate:(NSPredicate *)predicate sortDescriptors: (NSArray*) sortDescriptors
{
    NSFetchRequest * request = [APCScheduledTask request];
    request.predicate = predicate;
    request.sortDescriptors = sortDescriptors;
    return request;
}

- (NSArray *)scheduledTasksForPredicate:(NSPredicate *)predicate sortDescriptors: (NSArray*) sortDescriptors
{
    NSError* error;
    return [self.mainContext executeFetchRequest:[self requestForScheduledTasksForPredicate:predicate sortDescriptors:sortDescriptors] error:&error];
}

- (NSUInteger)countOfAllScheduledTasksForToday
{
    return [APCScheduledTask countOfAllScheduledTasksTodayInContext:self.mainContext];
}

- (NSUInteger) countOfCompletedScheduledTasksForToday
{
    return [APCScheduledTask countOfAllCompletedTasksTodayInContext:self.mainContext];
}

@end
