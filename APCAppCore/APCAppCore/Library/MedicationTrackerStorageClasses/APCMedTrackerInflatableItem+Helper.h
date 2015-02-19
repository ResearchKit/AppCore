//
//  APCMedTrackerInflatableItem+Helper.h
//  APCAppCore
//
//  Created by Ron Conescu on 2/18/15.
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCMedTrackerInflatableItem.h"


/**
 The +generateFromPlist method calls you back when
 it's done, using a block with this signature.
 */
typedef void (^APCMedTrackerFileLoadCallback) (NSArray *arrayOfGeneratedObjects,
                                               NSManagedObjectContext *contextWhereOperationRan,
                                               NSTimeInterval operationDuration);


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


@end
