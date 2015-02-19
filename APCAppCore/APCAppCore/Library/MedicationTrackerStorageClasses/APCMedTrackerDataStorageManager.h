//
//  APCMedTrackerDataStorageManager.h
//  APCAppCore
//
//  Created by Ron Conescu on 2/18/15.
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APCMedTrackerInflatableItem+Helper.h"


/**
 I need an asynchronous callback for one of the methods
 in this file.  This fits the bill.
 */
typedef void (^APCMedTrackerGenericCallback) (void);



@interface APCMedTrackerDataStorageManager : NSObject

/**
 Call this to initialize the storage manager.  Pass a block
 and a queue to do something immediately afterwards, or
 pass nil and/or NULL not to.
 */
+ (void) startupAndThenUseThisQueue: (NSOperationQueue *) queue
                           toDoThis: (APCMedTrackerGenericCallback) callbackBlock;

/**
 Get our singleton data-storage manager.
 */
+ (instancetype) defaultManager;

/**
 The NSManagedObjectContext used for all CoreData operations
 within the Medication Tracker.  Allocated the first time
 this class is referenced.
 */
@property (readonly) NSManagedObjectContext *context;

/**
 The operation queue used for all CoreData operations
 within the Medication Tracker.  Allocated the first time
 this class is referenced.
 */
@property (readonly) NSOperationQueue *queue;

/**
 A convenience method.  I use this internally; you might
 as well have access to it, too.  The idea:  go onto some
 queue, call this method, and you get a pointer to some
 context.  You can then forever use that context on
 that queue.  Once you let the context expire (say, set
 its variable to nil, and let ARC clean it up), all
 objects based on that context will be unusable -- which
 is a feature.
 */
- (NSManagedObjectContext *) newContextOnCurrentQueue;

@end
