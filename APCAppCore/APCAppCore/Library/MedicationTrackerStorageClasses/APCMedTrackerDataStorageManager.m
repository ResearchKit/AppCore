//
//  APCMedTrackerDataStorageManager.m
//  APCAppCore
//
//  Created by Ron Conescu on 2/18/15.
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCMedTrackerDataStorageManager.h"
#import "APCMedTrackerMedication+Helper.h"
#import "APCMedTrackerScheduleColor+Helper.h"
#import "APCMedTrackerPossibleDosage+Helper.h"
#import "NSOperationQueue+Helper.h"
#import "APCAppDelegate.h"
#import "NSManagedObject+APCHelper.h"
#import "APCLog.h"


static APCMedTrackerDataStorageManager *_defaultManager = nil;

static NSString * const FILE_WITH_PREDEFINED_MEDICATIONS = @"APCMedTrackerPredefinedMedications.plist";
static NSString * const FILE_WITH_PREDEFINED_SCHEDULE_COLORS = @"APCMedTrackerPredefinedScheduleColors.plist";
static NSString * const FILE_WITH_PREDEFINED_POSSIBLE_DOSAGES = @"APCMedTrackerPredefinedPossibleDosages.plist";
static NSString * const QUEUE_NAME = @"MedicationTracker query queue";
static dispatch_once_t _startupComplete = 0;



@interface APCMedTrackerDataStorageManager ()

@property (nonatomic, strong) NSOperationQueue *masterQueue;
@property (nonatomic, strong) NSManagedObjectContext *masterContext;

@end


@implementation APCMedTrackerDataStorageManager

+ (void) startupAndThenUseThisQueue: (NSOperationQueue *) queue
                           toDoThis: (APCMedTrackerGenericCallback) callbackBlock
{
    if (! _defaultManager)
    {
        dispatch_once (& _startupComplete, ^{
            [self generateDefaultManagerAndResourcesAndThenDoThis: callbackBlock
                                                      onThisQueue: queue];
        });
    }
    else
    {
        [self doThis: callbackBlock onThisQueue: queue];
    }
}

+ (void) doThis: (APCMedTrackerGenericCallback) callbackBlock
    onThisQueue: (NSOperationQueue *) consumerQueue
{
    if (consumerQueue != nil && callbackBlock != NULL)
    {
        [consumerQueue addOperationWithBlock:^{
            callbackBlock ();
        }];
    }
}

/**
 This should be called exactly once, from +startup.
 I just wanted to break it into its own method because
 it contains a bunch of confusing concepts, and it
 gets called from a block in +startup, which makes
 the logic kinda hard to follow.
 */
+ (void) generateDefaultManagerAndResourcesAndThenDoThis: (APCMedTrackerGenericCallback) callbackBlock
                                             onThisQueue: (NSOperationQueue *) consumerQueue
{
    /*
     Create the manager.
     */
    APCMedTrackerDataStorageManager *__block manager = [APCMedTrackerDataStorageManager new];
    _defaultManager = manager;


    /*
     Create the queue.
     */
    manager.masterQueue = [NSOperationQueue sequentialOperationQueueWithName: QUEUE_NAME];

    [manager.masterQueue addOperationWithBlock:^{

        NSDate* startDate = [NSDate date];


        /*
         Create the context.
         */
        manager.masterContext = [manager newContextOnCurrentQueue];


        /*
         (Re)load current static data values from disk
         (in case, say, we now have more medications, or
         our designers have changed the color palette).
         These methods are all sequential, in-line methods,
         because I designed them to be called from this
         method.
         */
        NSManagedObjectContext *context = manager.masterContext;
        NSMutableArray *allInflatedObjects = [NSMutableArray new];

        [allInflatedObjects addObjectsFromArray: [APCMedTrackerMedication reloadAllObjectsFromPlistFileNamed: FILE_WITH_PREDEFINED_MEDICATIONS usingContext: context]];
        [allInflatedObjects addObjectsFromArray: [APCMedTrackerScheduleColor reloadAllObjectsFromPlistFileNamed: FILE_WITH_PREDEFINED_SCHEDULE_COLORS usingContext: context]];
        [allInflatedObjects addObjectsFromArray: [APCMedTrackerPossibleDosage reloadAllObjectsFromPlistFileNamed: FILE_WITH_PREDEFINED_POSSIBLE_DOSAGES usingContext: context]];


        /*
         Save everything.
         */
        if (allInflatedObjects.count > 0)
        {
            NSError *error = nil;
            APCMedTrackerInflatableItem *someObject = allInflatedObjects.firstObject;
            [someObject saveToPersistentStore: &error];
        }


        NSTimeInterval operationDuration = [[NSDate date] timeIntervalSinceDate: startDate];
        APCLogDebug (@"(Re)loaded static MedTracker items from disk in %f seconds.  Loaded these items: %@", operationDuration, allInflatedObjects);


        /*
         Do what the calling method asked.
         */
        [self doThis: callbackBlock onThisQueue: consumerQueue];
    }];
}

+ (instancetype) defaultManager
{
    return _defaultManager;
}

/**
 Should be called exactly once, by +startup.
 */
- (id) init
{
    self = [super init];

    if (self)
    {
        // I'll fill these in shortly.
        _masterContext = nil;
        _masterQueue = nil;
    }

    return self;
}

- (NSManagedObjectContext *) context
{
    return self.masterContext;
}

- (NSOperationQueue *) queue
{
    return self.masterQueue;
}

- (NSManagedObjectContext *) newContextOnCurrentQueue
{
    APCAppDelegate *appDelegate = (APCAppDelegate *) [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *masterContextIThink = appDelegate.dataSubstrate.persistentContext;
    NSManagedObjectContext *localContext = [[NSManagedObjectContext alloc] initWithConcurrencyType: NSPrivateQueueConcurrencyType];
    localContext.parentContext = masterContextIThink;
    return localContext;
}

@end












