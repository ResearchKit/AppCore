//
//  APCMedTrackerInflatableItem+Helper.h
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
//

#import "APCMedTrackerInflatableItem.h"


/**
 The +reloadAllFromPlist method calls you back when
 it's done, using a block with this signature.
 */
typedef void (^APCMedTrackerFileLoadCallback) (NSArray *arrayOfGeneratedObjects,
                                               NSTimeInterval operationDuration);



/**
 The +fetchAll methods will call you back when
 they're done, using a block with this signature.

 Note that "arrayOfGeneratedObjects" and "error" are
 passed to you straight from the output of a CoreData
 "fetch request."  This means we have to interpret them
 in precise ways:
 - the array will be nil if there was an error
 - the array will have stuff in it if there was stuff to be found
 - the array will be empty if there were no items of the type you
 requested.  You may consider this an error -- it depends on
 your business logic.

 Please see -[NSManagedObjectContext executeFetchRequest:]
 for a formal and complete description of those rules.
 */
typedef void (^APCMedTrackerQueryCallback) (NSArray *arrayOfGeneratedObjects,
                                            NSTimeInterval operationDuration,
                                            NSError *error);




@interface APCMedTrackerInflatableItem (Helper)

/**
 Attempts to load the stuff in the specified file as
 objects of whatever subclass of mine is executing this
 code.
 */
+ (NSArray *) reloadAllObjectsFromPlistFileNamed: (NSString *) fileName
                                    usingContext: (NSManagedObjectContext *) context;

/**
 Runs a query which loads all objects of this class in CoreData.
 Passes that array back to you in the block you specify.
 
 Intended to be used for our very short lists:  medication names,
 colors, etc.  This merely loads a fetch request and extracts
 all items from it; it can easily be done in other ways.
 */
+ (void) fetchAllFromCoreDataAndUseThisQueue: (NSOperationQueue *) someQueue
                            toDoThisWhenDone: (APCMedTrackerQueryCallback) callbackBlock;

@end
