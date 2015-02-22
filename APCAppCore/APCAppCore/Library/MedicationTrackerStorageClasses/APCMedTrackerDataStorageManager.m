//
//  APCMedTrackerDataStorageManager.m
//  AppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCMedTrackerDataStorageManager.h"
#import "APCMedTrackerMedication+Helper.h"
#import "APCMedTrackerPrescriptionColor+Helper.h"
#import "APCMedTrackerPossibleDosage+Helper.h"
#import "NSOperationQueue+Helper.h"
#import "APCAppDelegate.h"
#import "NSManagedObject+APCHelper.h"
#import "APCLog.h"


static APCMedTrackerDataStorageManager *_defaultManager = nil;

static NSString * const FILE_WITH_PREDEFINED_MEDICATIONS = @"APCMedTrackerPredefinedMedications.plist";
static NSString * const FILE_WITH_PREDEFINED_POSSIBLE_DOSAGES = @"APCMedTrackerPredefinedPossibleDosages.plist";
static NSString * const FILE_WITH_PREDEFINED_PRESCRIPTION_COLORS = @"APCMedTrackerPredefinedPrescriptionColors.plist";
static NSString * const QUEUE_NAME = @"MedicationTracker query queue";
static dispatch_once_t _startupComplete = 0;



@interface APCMedTrackerDataStorageManager ()

@property (nonatomic, strong) NSOperationQueue *masterQueue;
@property (nonatomic, strong) NSManagedObjectContext *masterContext;

@end


@implementation APCMedTrackerDataStorageManager

+ (void) startupReloadingDefaults: (BOOL) shouldReloadPlistFiles
              andThenUseThisQueue: (NSOperationQueue *) queue
                         toDoThis: (APCMedTrackerGenericCallback) callbackBlock
{
    if (! _defaultManager)
    {
        dispatch_once (& _startupComplete, ^{

            APCMedTrackerDataStorageManager *__block manager = [APCMedTrackerDataStorageManager new];
            _defaultManager = manager;

            manager.masterQueue = [NSOperationQueue sequentialOperationQueueWithName: QUEUE_NAME];
            
            [manager.masterQueue addOperationWithBlock:^{

                manager.masterContext = [manager newContextOnCurrentQueue];

                APCLogDebug (@"MedTracker defaultManager has been created.");
                
                if (shouldReloadPlistFiles)
                {
                    [self reloadStaticContentFromPlistFiles];
                }

                [self doThis: callbackBlock onThisQueue: queue];
            }];
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
 (Re)load current static data values from disk
 (in case, say, we now have more medications, or
 our designers have changed the color palette).

 This should be called exactly once, from +startup.
 This is called from within a block on our special
 queue.
 */
+ (void) reloadStaticContentFromPlistFiles
{
    APCMedTrackerDataStorageManager *manager = [self defaultManager];
    NSManagedObjectContext *context = manager.masterContext;
    NSMutableArray *allInflatedObjects = [NSMutableArray new];
    NSDate *startDate = [NSDate date];

    /*
     These methods are sequential, in-line methods,
     because I designed them to be called from this
     method.
     */
    [allInflatedObjects addObjectsFromArray: [APCMedTrackerMedication reloadAllObjectsFromPlistFileNamed: FILE_WITH_PREDEFINED_MEDICATIONS usingContext: context]];
    [allInflatedObjects addObjectsFromArray: [APCMedTrackerPossibleDosage reloadAllObjectsFromPlistFileNamed: FILE_WITH_PREDEFINED_POSSIBLE_DOSAGES usingContext: context]];
    [allInflatedObjects addObjectsFromArray: [APCMedTrackerPrescriptionColor reloadAllObjectsFromPlistFileNamed: FILE_WITH_PREDEFINED_PRESCRIPTION_COLORS usingContext: context]];


    /*
     Save to CoreData.
     */
    NSString *errorMessage = nil;

    if (allInflatedObjects.count > 0)
    {
        NSError *error = nil;
        APCMedTrackerInflatableItem *someObject = allInflatedObjects.firstObject;

        BOOL itWorked = [someObject saveToPersistentStore: &error];

        if (itWorked)
        {
            errorMessage = @"Everything seems to have worked perfectly.";
        }
        else if (error == nil)
        {
            errorMessage = @"Error: [Couldn't load files, but I have no information about why... ?!?]";
        }
        else
        {
            errorMessage = [NSString stringWithFormat: @"Error: [%@]", error];
        }
    }


    NSTimeInterval operationDuration = [[NSDate date] timeIntervalSinceDate: startDate];

    APCLogDebug (@"(Re)loaded static MedTracker items from disk in %f seconds.  %@  Loaded these items: %@", operationDuration, errorMessage, allInflatedObjects);
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












