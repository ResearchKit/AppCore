// 
//  APCMedTrackerDataStorageManager.h 
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
 
#import <Foundation/Foundation.h>
#import "APCMedTrackerInflatableItem+Helper.h"



extern NSString *const kAPCMedicationTrackerResourceNameMedication;
extern NSString *const kAPCMedicationTrackerResourceNameDosages;
extern NSString *const kAPCMedicationTrackerResourceNameColors;

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
+ (void) startupReloadingDefaults: (BOOL) shouldReloadPlistFiles
              andThenUseThisQueue: (NSOperationQueue *) queue
                         toDoThis: (APCMedTrackerGenericCallback) callbackBlock;

/**
  * @brief  Use this to initialize the storage manager with custom medication
  *         data. Optionally, pass a block and a queue to do something immediately afterward.
  *
  * @param  bundle          The bundle that will be used for loading the files.
  * 
  * @param  resourceNames   A dictionary of resource names that will be used for loading information.
  *
  * @param  queue           A queue that will be used to do something immediately afterwards, can be nil.
  *
  * @param  callbackBlock   A block to do something afterwards on the queue that is provided, can be NULL.
  *
  * @note   In order to execute the callback block, a queue must be provided.
  *         Otherwise the block will not be executed.
  */
+ (void) startupWithCustomDataInBundle: (NSBundle *) bundle
                     withResourceNames: (NSDictionary *) resourceNames
                   andThenUseThisQueue: (NSOperationQueue *) queue
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
