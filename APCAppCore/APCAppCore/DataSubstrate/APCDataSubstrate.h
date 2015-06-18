// 
//  APCDataSubstrate.h 
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
#import <CoreData/CoreData.h>
#import <HealthKit/HealthKit.h>
#import "APCParameters.h"
#import "APCNewsFeedManager.h"

@class APCUser;

@interface APCDataSubstrate : NSObject <APCParametersDelegate>


#pragma mark - Initializer

- (instancetype)initWithPersistentStorePath:(NSString *)storePath additionalModels:(NSManagedObjectModel *)mergedModels studyIdentifier:(NSString *)studyIdentifier;


#pragma mark - ResearchKit Subsystem Public Properties & Passive Location Tracking

@property (assign) BOOL justJoined;
@property (strong, nonatomic) NSString *logDirectory;
@property (nonatomic, strong) APCUser *currentUser;


#pragma mark - CoreData

@property (nonatomic, strong) NSString *storePath;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;

/** Main context for use in View Controllers, Fetch Results Controllers etc. */
@property (nonatomic, strong) NSManagedObjectContext * mainContext;

/** Persistent context: Parent of main context.
 *  Please create a child context of persistentContext for any background processing tasks.
 */
@property (nonatomic, strong) NSManagedObjectContext * persistentContext;


#pragma mark - Core Data Public Methods

/** EXERCISE CAUTION IN CALLING THIS METHOD. */
- (void)resetCoreData;


#pragma mark - Core Data Helpers - ONLY RETURNS in NSManagedObjects in mainContext

/**
 Tracks the total number of required tasks for "today," whenever
 "today" is.  This is updated by the Activities screen, or the
 CoreData method called by that screen, whenever appropriate.
 */
@property (readonly) NSUInteger countOfTotalRequiredTasksForToday;

/**
 Tracks the total number of completed tasks for "today," whenever
 "today" is.  This is updated by the Activities screen, or the
 CoreData method called by that screen, whenever appropriate.
 */
@property (readonly) NSUInteger countOfTotalCompletedTasksForToday;

/**
 Called by the Activities screen, or the CoreData method
 called by that screen, whenever appropriate.  Updates the
 two -count properties on this object.
 */
- (void) updateCountOfTotalRequiredTasksForToday: (NSUInteger) countOfRequiredTasks
                     andTotalCompletedTasksToday: (NSUInteger) countOfCompletedTasks;

/**
 Former name for -countOfTotalRequiredTasksForToday.
 Please use that method instead.

 This method used to run a CoreData query which counted
 today's total (completed + uncompleted) tasks.  The
 replacement method, in contrast, simply tracks the most
 recent stuff appearing on the Activities screen, which
 was the point.
 */
- (NSUInteger)countOfAllScheduledTasksForToday  __attribute__((deprecated("Please use -countOfTotalRequiredTasksForToday instead.")));

/**
 Former name for -countOfTotalCompletedTasksForToday.
 Please use that method instead.

 This method used to run a CoreData query which counted
 today's completed tasks.  The replacement method, in
 contrast, simply tracks the most recent stuff appearing
 on the Activities screen, which was the point.
 */
- (NSUInteger) countOfCompletedScheduledTasksForToday  __attribute__((deprecated("Please use -countOfTotalCompletedTasksForToday instead.")));


#pragma mark - HealthKit

@property (nonatomic, strong) HKHealthStore *healthStore;


#pragma mark - Parameters

@property (strong, nonatomic) APCParameters *parameters;

#pragma mark - News Feed

@property (strong, nonatomic) APCNewsFeedManager *newsFeedManager;

@end
