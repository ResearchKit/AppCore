//
//  APCMedTrackerInflatableItem+Helper.m
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
//

#import "APCMedTrackerInflatableItem+Helper.h"
#import "NSManagedObject+APCHelper.h"
#import "APCAppDelegate.h"
#import "APCMedTrackerDataStorageManager.h"
#import "APCLog.h"

@implementation APCMedTrackerInflatableItem (Helper)

+ (void) fetchAllFromCoreDataAndUseThisQueue: (NSOperationQueue *) someQueue
                            toDoThisWhenDone: (APCMedTrackerQueryCallback) callbackBlock
{
    [APCMedTrackerDataStorageManager.defaultManager.queue addOperationWithBlock:^{

        NSDate *startTime = [NSDate date];

        NSManagedObjectContext *context = APCMedTrackerDataStorageManager.defaultManager.context;

        // Fetch all items of my current subclass.
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName: NSStringFromClass ([self class])];

        NSError *error = nil;
        NSArray *foundItems = [context executeFetchRequest: request error: &error];

        NSTimeInterval operationDuration = [[NSDate date] timeIntervalSinceDate: startTime];

        if (callbackBlock != NULL)
        {
            [someQueue addOperationWithBlock: ^{
                callbackBlock (foundItems, operationDuration, error);
            }];
        }
    }];
}

+ (NSArray *) reloadAllObjectsFromPlistFileNamed: (NSString *) fileName
                                    usingContext: (NSManagedObjectContext *) context
{
    NSMutableArray *inflatedObjects = [NSMutableArray new];
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
                 We'll save the object in the calling method.
                 */
            }];
        }
    }

    return inflatedObjects;
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

        if (foundItems == nil)
        {
            // Something went wrong!  (See definition of -executeFetchRequest for details.)
            // For now, silently absorb it.  As we debug this, I'll look for errors.
        }

        else if (foundItems.count == 0)
        {
            // No matching items found.  No problem.
        }

        else
        {
            for (APCMedTrackerInflatableItem * foundItem in foundItems)
            {
                /*
                 The item we just generated will, by definition,
                 be in the list of stuff the Context will find with
                 this search.  Skip it.
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
