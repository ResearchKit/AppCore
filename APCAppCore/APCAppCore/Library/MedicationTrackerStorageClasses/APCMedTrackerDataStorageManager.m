// 
//  APCMedTrackerDataStorageManager.m 
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
 
#import "APCMedTrackerDataStorageManager.h"
#import "APCMedTrackerMedication+Helper.h"
#import "APCMedTrackerPrescriptionColor+Helper.h"
#import "APCMedTrackerPossibleDosage+Helper.h"
#import "NSOperationQueue+Helper.h"
#import "APCAppDelegate.h"
#import "NSManagedObject+APCHelper.h"
#import "APCLog.h"


static APCMedTrackerDataStorageManager *_defaultManager = nil;

NSString *const kAPCMedicationTrackerResourceNameMedication = @"medications";
NSString *const kAPCMedicationTrackerResourceNameDosages    = @"dosages";
NSString *const kAPCMedicationTrackerResourceNameColors     = @"colors";

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
    [self sharedStartupWithDefaults: shouldReloadPlistFiles
                           inBundle: nil
                  withResourceNames: nil
                andThenUseThisQueue: queue
                           toDoThis: callbackBlock];
}

+ (void) startupWithCustomDataInBundle: (NSBundle *) bundle
                     withResourceNames: (NSDictionary *) resourceNames
                   andThenUseThisQueue: (NSOperationQueue *) queue
                              toDoThis: (APCMedTrackerGenericCallback) callbackBlock
{
    [self sharedStartupWithDefaults: NO
                           inBundle: bundle
                  withResourceNames: resourceNames
                andThenUseThisQueue: queue
                           toDoThis: callbackBlock];
}

+ (void) sharedStartupWithDefaults: (BOOL) shouldReloadPlistFiles
                          inBundle: (NSBundle *) bundle
                 withResourceNames: (NSDictionary *) resourceNames
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
                    [self reloadStaticContentFromPlistFilesUsingBundle:nil withResourceNames:nil];
                }
                else if (bundle && resourceNames)
                {
                    // load the data using the bundle that is provided.
                    [self reloadStaticContentFromPlistFilesUsingBundle:bundle withResourceNames:resourceNames];
                }
                else
                {
                    APCLogError(@"We are here because neither the default nor custom resources were asked to be loaded.");
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
+ (void) reloadStaticContentFromPlistFilesUsingBundle: (NSBundle *) bundle
                                    withResourceNames: (NSDictionary *) resourceNames
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
    
    NSString *medResourceName = nil;
    NSString *doseResourceName = nil;
    NSString *colorResourceName = nil;
    
    if (resourceNames[kAPCMedicationTrackerResourceNameMedication])
    {
        medResourceName = resourceNames[kAPCMedicationTrackerResourceNameMedication];
    }
    else
    {
        medResourceName = FILE_WITH_PREDEFINED_MEDICATIONS;
        // The default files are in the AppCore bundle, that why we need to set it to nil
        bundle = nil;
    }
    
    [allInflatedObjects addObjectsFromArray: [APCMedTrackerMedication reloadAllObjectsFromPlistFileNamed: medResourceName
                                                                                            usingContext: context
                                                                                                inBundle: bundle]];
    
    if (resourceNames[kAPCMedicationTrackerResourceNameDosages])
    {
        doseResourceName = resourceNames[kAPCMedicationTrackerResourceNameDosages];
    }
    else
    {
        doseResourceName = FILE_WITH_PREDEFINED_POSSIBLE_DOSAGES;
        // The default files are in the AppCore bundle, that why we need to set it to nil
        bundle = nil;
    }
    
    [allInflatedObjects addObjectsFromArray: [APCMedTrackerPossibleDosage reloadAllObjectsFromPlistFileNamed: doseResourceName
                                                                                                usingContext: context
                                                                                                    inBundle: bundle]];
    
    if (resourceNames[kAPCMedicationTrackerResourceNameColors])
    {
        colorResourceName = resourceNames[kAPCMedicationTrackerResourceNameColors];
    }
    else
    {
        colorResourceName = FILE_WITH_PREDEFINED_PRESCRIPTION_COLORS;
        // The default files are in the AppCore bundle, that why we need to set it to nil
        bundle = nil;
    }
    
    [allInflatedObjects addObjectsFromArray: [APCMedTrackerPrescriptionColor reloadAllObjectsFromPlistFileNamed: colorResourceName
                                                                                                   usingContext: context
                                                                                                       inBundle: bundle]];

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












