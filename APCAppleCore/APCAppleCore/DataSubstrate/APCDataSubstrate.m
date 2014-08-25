//
//  APCDataSubstrate.m
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 8/25/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCDataSubstrate.h"
#import <CoreData/CoreData.h>

@interface APCDataSubstrate ()
@property (nonatomic, strong) NSManagedObjectModel * managedObjectModel;
@property (nonatomic, strong) NSPersistentStoreCoordinator * persistentStoreCoordinator;

@end

@implementation APCDataSubstrate

- (instancetype)initWithPersistentStorePath: (NSString*) storePath additionalModels:(NSManagedObjectModel *)mergedModels
{
    self = [super init];
    if (self) {
        [self setUpCoreDataStackWithPersistentStorePath:storePath additionalModels:mergedModels];
    }
    return self;
}


- (void) setUpCoreDataStackWithPersistentStorePath: (NSString*) storePath additionalModels:(NSManagedObjectModel *)mergedModels
{
    [self loadManagedObjectModel:mergedModels];
    [self initializePersistentStoreCoordinator:storePath];
    [self createManagedObjectContexts];
    
}

- (void) loadManagedObjectModel: (NSManagedObjectModel*) mergedModels
{
    // Initialize managed object store
    NSString* bundlePath = [[NSBundle mainBundle] pathForResource:@"APCAppleCoreBundle" ofType:@"bundle"];
    
    NSBundle* bundle = [NSBundle bundleWithPath:bundlePath];
    
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
    self.persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    NSError * error;
    NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption: @(YES),
                 NSInferMappingModelAutomaticallyOption: @(YES) };
    [self.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[NSURL fileURLWithPath:storePath] options:options error:&error];
    NSAssert([[NSFileManager defaultManager] fileExistsAtPath:storePath], @"Database Not Created");
}

- (void) createManagedObjectContexts
{
    self.persistentContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    self.persistentContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
    
    self.mainContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    self.mainContext.parentContext = self.persistentContext;
}

@end
