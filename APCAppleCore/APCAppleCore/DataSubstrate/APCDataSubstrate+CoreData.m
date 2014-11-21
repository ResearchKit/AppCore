//
//  APCDataSubstrate+CoreData.m
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 8/26/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCDataSubstrate+CoreData.h"
#import "APCAppleCore.h"
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
    NSError * error;
    NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption: @(YES),
                              NSInferMappingModelAutomaticallyOption: @(YES)
                              };
    
    NSPersistentStore *persistentStore = [self.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[NSURL fileURLWithPath:self.storePath] options:options error:&error];
    if (!persistentStore) {
        //TODO: Address removing persistent store in production
        NSError * localError;
        [self removeSqliteStore];
        [self.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[NSURL fileURLWithPath:self.storePath] options:options error:&localError];
        [localError handle];
    }
    NSAssert([[NSFileManager defaultManager] fileExistsAtPath:self.storePath], @"Database Not Created");
}

- (void) removeSqliteStore
{
    NSError* localError;
    [[NSFileManager defaultManager] removeItemAtPath:self.storePath error:&localError];
    [localError handle];
}

- (void) createManagedObjectContexts
{
    self.persistentContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    self.persistentContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
    
    self.mainContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    self.mainContext.parentContext = self.persistentContext;
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
    [error handle];
    [self removeSqliteStore];
    [self setUpPersistentStore];
    APCAppDelegate * appDelegate = [UIApplication sharedApplication].delegate;
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

- (NSUInteger)allScheduledTasksForToday
{
    NSFetchRequest * request = [APCScheduledTask request];
    NSError* error;
    return [self.mainContext countForFetchRequest:request error:&error];
}

- (NSUInteger)completedScheduledTasksForToday
{
    NSFetchRequest * request = [APCScheduledTask request];
    request.predicate = [NSPredicate predicateWithFormat:@"completed == %@", @YES];
    NSError* error;
    return [self.mainContext countForFetchRequest:request error:&error];
}

@end
