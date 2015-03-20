// 
//  APCDataSubstrate+CoreData.m 
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//
 
#import "APCDataSubstrate+CoreData.h"
#import "APCAppCore.h"
#import <CoreData/CoreData.h>
#import "NSError+APCAdditions.h"


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
    NSError *errorOpeningOrCreatingCoreDataFile = nil;
    NSURL   *persistentStoreUrl  = [NSURL fileURLWithPath: self.storePath];
    BOOL    fileAlreadyExists    = [[NSFileManager defaultManager] fileExistsAtPath: self.storePath];

    NSDictionary *options = @{ NSMigratePersistentStoresAutomaticallyOption : @(YES),
                               NSInferMappingModelAutomaticallyOption       : @(YES)
                               };

    NSPersistentStore *persistentStore = [self.persistentStoreCoordinator addPersistentStoreWithType: NSSQLiteStoreType
                                                                                       configuration: nil
                                                                                                 URL: persistentStoreUrl
                                                                                             options: options
                                                                                               error: & errorOpeningOrCreatingCoreDataFile];

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
        NSError *catastrophe = nil;

        if (fileAlreadyExists)
        {
            catastrophe = [NSError errorWithCode: APCErrorCode_CoreData_CantOpenExistingDatabase
                                          domain: kAPCError_CoreData_Domain
                                   failureReason: kAPCError_CoreData_CantOpenDatabase_Reason
                              recoverySuggestion: kAPCError_CoreData_CantOpenDatabase_Suggestion
                                 relatedFilePath: self.storePath
                                      relatedURL: persistentStoreUrl
                                     nestedError: errorOpeningOrCreatingCoreDataFile];
        }
        else
        {
            catastrophe = [NSError errorWithCode: APCErrorCode_CoreData_CantCreateDatabase
                                          domain: kAPCError_CoreData_Domain
                                   failureReason: kAPCError_CoreData_CantCreateDatabase_Reason
                              recoverySuggestion: kAPCError_CoreData_CantCreateDatabase_Suggestion
                                 relatedFilePath: self.storePath
                                      relatedURL: persistentStoreUrl
                                     nestedError: errorOpeningOrCreatingCoreDataFile];
        }

        APCLogError2 (catastrophe);


        /*
         Report this actually-catastrophic error to the app.
         It'll display it when it gets a chance -- a few
         milliseconds from now (like, thousands of actual
         instructions from now), asynchronously.
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
