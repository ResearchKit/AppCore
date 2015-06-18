// 
//  APCMedTrackerInflatableItem+Helper.m 
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
                                        inBundle: (NSBundle *) bundle
{
    NSMutableArray *inflatedObjects = [NSMutableArray new];
    NSURL *fileUrl = nil;
    
    if (bundle) {
        fileUrl = [bundle URLForResource:fileName
                           withExtension:@"plist"];
    } else {
        fileUrl = [self urlForBundleFileWithName: fileName];
    }
    
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
				
                APCMedTrackerInflatableItem *existingObjectWithThisName = [self itemWithSameNameAs: generatedObject
                                                                                         inContext: context];
                if (existingObjectWithThisName)
                {
                    APCMedTrackerInflatableItem *itemToSave = existingObjectWithThisName;

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
