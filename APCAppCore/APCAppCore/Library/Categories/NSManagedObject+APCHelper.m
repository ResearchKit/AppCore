//
//  NSManagedObject+APCHelper.m
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 8/28/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "NSManagedObject+APCHelper.h"

@implementation NSManagedObject (APCHelper)

+ (instancetype) newObjectForContext: (NSManagedObjectContext*) context
{
    return  [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class]) inManagedObjectContext:context];
    
}

+(NSFetchRequest *)request
{
    return [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([self class])];
}

- (BOOL)saveToPersistentStore:(NSError *__autoreleasing *)error
{
    __block NSError *localError = nil;
    NSManagedObjectContext *contextToSave = self.managedObjectContext;
    while (contextToSave) {
        __block BOOL success;
        [contextToSave obtainPermanentIDsForObjects:[[contextToSave insertedObjects] allObjects] error:&localError];
        if (localError) {
            if (error) *error = localError;
            return NO;
        }
        
        [contextToSave performBlockAndWait:^{
            success = [contextToSave save:&localError];
            if (! success && localError == nil) NSLog(@"Saving of managed object context failed, but a `nil` value for the `error` argument was returned. This typically indicates an invalid implementation of a key-value validation method exists within your model. This violation of the API contract may result in the save operation being mis-interpretted by callers that rely on the availability of the error.");
        }];
        
        if (! success) {
            if (error) *error = localError;
            return NO;
        }
        
        if (! contextToSave.parentContext && contextToSave.persistentStoreCoordinator == nil) {
            NSLog(@"Reached the end of the chain of nested managed object contexts without encountering a persistent store coordinator. Objects are not fully persisted.");
            return NO;
        }
        contextToSave = contextToSave.parentContext;
    }
    
    return YES;
}

@end
