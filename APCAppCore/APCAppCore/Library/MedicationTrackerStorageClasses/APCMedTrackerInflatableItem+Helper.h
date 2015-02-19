//
//  APCMedTrackerInflatableItem+Helper.h
//  APCAppCore
//
//  Created by Ron Conescu on 2/18/15.
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCMedTrackerInflatableItem.h"


/**
 The +reloadAllFromPlist method calls you back when
 it's done, using a block with this signature.
 */
typedef void (^APCMedTrackerFileLoadCallback) (NSArray *arrayOfGeneratedObjects,
                                               NSManagedObjectContext *contextWhereOperationRan,
                                               NSTimeInterval operationDuration);

/**
 The +loadAllFromCoreData method calls you back when
 it's done, using a block with this signature.
 */
typedef void (^APCMedTrackerQueryCallback) (NSArray *arrayOfGeneratedObjects,
                                            NSManagedObjectContext *contextWhereOperationRan,
                                            NSTimeInterval operationDuration,
                                            NSError *error);


@interface APCMedTrackerInflatableItem (Helper)

/**
 Attempts to load the stuff in the specified file as
 objects of whatever subclass of mine is executing this
 code.  If successful, the objects are saved to CoreData,
 and an array of those created objects is returned in
 the specified callback block.
 */
+ (void) reloadAllFromPlistFileNamed: (NSString *) fileName
                          usingQueue: (NSOperationQueue *) queue
                   andDoThisWhenDone: (APCMedTrackerFileLoadCallback) callbackBlock;

/**
 Runs a query which loads all objects of this class in CoreData.
 Passes that array back to you in the block you specify.
 
 Intended to be used for our very short lists:  medication names,
 colors, etc.  This merely loads a fetch request and extracts
 all items from it; it can easily be done in other ways.
 */
+ (void) loadAllFromCoreDataUsingQueue: (NSOperationQueue *) queue
                     andDoThisWhenDone: (APCMedTrackerQueryCallback) callbackBlock;

@end
