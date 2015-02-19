//
//  APCMedTrackerInflatableItem+Helper.m
//  APCAppCore
//
//  Created by Ron Conescu on 2/18/15.
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCMedTrackerInflatableItem+Helper.h"
#import "NSManagedObject+APCHelper.h"
#import "APCAppDelegate.h"

@implementation APCMedTrackerInflatableItem (Helper)

+ (void) loadAllFromCoreDataUsingQueue: (NSOperationQueue *) queue
                     andDoThisWhenDone: (APCMedTrackerQueryCallback) callbackBlock
{
    [queue addOperationWithBlock:^{

        NSDate *startTime = [NSDate date];
        NSManagedObjectContext *context = [self newContextOnCurrentQueue];
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName: NSStringFromClass ([self class])];
        NSError *error = nil;

        NSArray *foundItems = [context executeFetchRequest: request error: &error];

        NSTimeInterval operationDuration = [[NSDate date] timeIntervalSinceDate: startTime];

        callbackBlock (foundItems, context, operationDuration, error);
    }];
}

+ (void) reloadAllFromPlistFileNamed: (NSString *) fileName
                          usingQueue: (NSOperationQueue *) queue
                   andDoThisWhenDone: (APCMedTrackerFileLoadCallback) callbackBlock
{
    // This is our pattern for creating and saving objects.
    [queue addOperationWithBlock: ^{

        NSDate *startTime = [NSDate date];
        NSMutableArray *inflatedObjects = [NSMutableArray new];
        NSManagedObjectContext *context = [self newContextOnCurrentQueue];

        NSURL *fileUrl = [self urlForBundleFileWithName: fileName];
        NSArray *rawData = [NSArray arrayWithContentsOfURL: fileUrl];

        for (id probablyDictionary in rawData)
        {
            if ([probablyDictionary isKindOfClass: [NSDictionary class]])
            {
                NSDictionary *incomingData = probablyDictionary;

                /*
                 We can also use -performBlock:.  For this, I want
                 -performBlockAndWait, because I want to loop through
                 the list of stuff coming from the file.
                 */
                [context performBlockAndWait: ^{

                    APCMedTrackerInflatableItem *generatedObject = [[self class] newObjectForContext: context];

                    [inflatedObjects addObject: generatedObject];

                    /*
                     Attempt to fill in the values from the entries
                     in the plist file.  Silently absorb any problems --
                     it's just a text file, and might contain notes,
                     or out-of-date ideas, or whatever.  Slurp in
                     what we can.
                     */
                    for (NSString *key in incomingData.allKeys)
                    {
                        id value = incomingData [key];

                        NSString *theSetMethod = [NSString stringWithFormat: @"set%@%@:",
                                                  [key substringToIndex: 1].capitalizedString,
                                                  [key substringFromIndex: 1]];

                        if ([generatedObject respondsToSelector: NSSelectorFromString (theSetMethod)])
                        {
                            [generatedObject setValue: value forKey: key];
                        }
                    }

                    APCMedTrackerInflatableItem *itemToSave = generatedObject;
                    APCMedTrackerInflatableItem *existingObjectWithThisName = [self itemWithSameNameAs: generatedObject
                                                                                             inContext: context];
                    if (existingObjectWithThisName)
                    {
                        itemToSave = existingObjectWithThisName;

                        for (NSString *key in incomingData.allKeys)
                        {
                            if (! [key isEqualToString: NSStringFromSelector (@selector (name))])
                            {
                                id value = [generatedObject valueForKey: key];
                                [itemToSave setValue: value forKey: key];
                            }
                        }

                        [context deleteObject: generatedObject];
                    }

                    /*
                     Whew.  Save it.
                     */
                    NSError *error = nil;
                    [itemToSave saveToPersistentStore: &error];
                }];
            }
        }

        NSTimeInterval operationDuration = [[NSDate date] timeIntervalSinceDate: startTime];

        /*
         Done!  Report to the user.  Remember we're running a
         function (a block) on the queue she specified.
         */
        if (callbackBlock != NULL)
        {
            callbackBlock (inflatedObjects, context, operationDuration);
        }
    }];
}



// ---------------------------------------------------------
#pragma mark - Utilities
// ---------------------------------------------------------

+ (NSURL *) urlForBundleFileWithName: (NSString *) name
{
    NSString *extension = [name pathExtension];
    NSString *baseName = [name substringToIndex: name.length - (extension.length + 1)];
    NSURL *url = [[NSBundle bundleForClass: [self class]] URLForResource: baseName withExtension: extension];
    return url;
}

+ (NSManagedObjectContext *) newContextOnCurrentQueue
{
    APCAppDelegate *appDelegate = (APCAppDelegate *) [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *masterContextIThink = appDelegate.dataSubstrate.persistentContext;
    NSManagedObjectContext *localContext = [[NSManagedObjectContext alloc] initWithConcurrencyType: NSPrivateQueueConcurrencyType];
    localContext.parentContext = masterContextIThink;
    return localContext;
}

/**
 For other validation ideas, see:
 https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/CoreData/Articles/cdValidation.html#//apple_ref/doc/uid/TP40004807-SW2
 and
 https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/KeyValueCoding/Articles/Validation.html#//apple_ref/doc/uid/20002173
 */
+ (APCMedTrackerInflatableItem *) itemWithSameNameAs: (APCMedTrackerInflatableItem *) newlyGeneratedItem
                                           inContext: (NSManagedObjectContext *) context
{
    APCMedTrackerInflatableItem *result = nil;
    NSString *name = newlyGeneratedItem.name;

    if (name.length > 0)
    {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName: NSStringFromClass ([self class])];
        request.predicate = [NSPredicate predicateWithFormat: @"%K == %@", NSStringFromSelector (@selector (name)), name];
        NSError *error = nil;
        NSArray *foundItems = [context executeFetchRequest: request
                                                     error: &error];

        if (error == nil)
        {
            for (APCMedTrackerInflatableItem * foundItem in foundItems)
            {
                /*
                 The item we just generated will, by definition,
                 be in the list of stuff the Context will find with
                 this search.
                 */
                if (! [foundItem.objectID isEqual: newlyGeneratedItem.objectID])
                {
                    result = foundItem;
                    break;
                }
            }
        }
    }
    
    return result;
}

@end
