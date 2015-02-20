//
//  APCMedTrackerInflatableItem+Helper.h
//  AppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCMedTrackerInflatableItem.h"


/**
 The +reloadAllFromPlist method calls you back when
 it's done, using a block with this signature.
 */
typedef void (^APCMedTrackerFileLoadCallback) (NSArray *arrayOfGeneratedObjects,
                                               NSTimeInterval operationDuration);

/**
 The +loadAllFromCoreData method calls you back when
 it's done, using a block with this signature.
 
 Note that arrayOfGeneratedObjects and error are passed
 to you straight from the output of
 -[NSManagedObjectContext executeFetchRequest:].  Please
 see that method for descriptions of those values.  In
 particular, note that the array will be nil if there
 was an error, but an empty array if there were simply
 no items found.
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
