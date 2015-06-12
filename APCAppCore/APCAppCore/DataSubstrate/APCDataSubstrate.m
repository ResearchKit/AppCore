// 
//  APCDataSubstrate.m 
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
 
#import "APCDataSubstrate.h"
#import "APCConstants.h"
#import "APCUser.h"
#import "APCAppDelegate.h"		// should be replaced
#import "APCLog.h"

#import "NSDate+Helper.h"
#import "APCTask+AddOn.h"
#import "APCSchedule+AddOn.h"
#import "APCScheduledTask+AddOn.h"
#import "NSError+APCAdditions.h"
#import "APCScheduler.h"


static int dateCheckTimeInterval = 60;

static NSString * const kCoreDataErrorDomain                   = @"kAPCError_CoreData_Domain";

static NSInteger  const kErrorCantCreateDatabase_Code          = 1;
static NSString * const kErrorCantCreateDatabase_Reason        = @"Unable to Create Database";
static NSString * const kErrorCantCreateDatabase_Suggestion    = (@"We were unable to create a place to "
                                                                  "save your data. Please exit the app and "
                                                                  "try again. If the problem reoccurs, please "
                                                                  "uninstall the app and try once more.");

static NSInteger  const kErrorCantOpenDatabase_Code            = 2;
static NSString * const kErrorCantOpenDatabase_Reason          = @"Unable to Open Database";
static NSString * const kErrorCantOpenDatabase_Suggestion      = (@"Unable to open your existing data file. "
                                                                  "Please exit the app and try again. If the "
                                                                  "problem reoccurs, please uninstall and "
                                                                  "reinstall the app.");

static NSString * const kAPCJSONFileKeySchedules = @"schedules";
static NSString * const kAPCJSONFileKeyTasks     = @"tasks";


@interface APCDataSubstrate ()
@property (nonatomic, strong) NSTimer *dateChangeTestTimer;
@property (nonatomic, strong) NSDate *lastKnownDate;
@property (nonatomic, assign) NSUInteger countOfTotalRequiredTasksForToday;
@property (nonatomic, assign) NSUInteger countOfTotalCompletedTasksForToday;
@end

@implementation APCDataSubstrate

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithPersistentStorePath:(NSString *)storePath
						   additionalModels:(NSManagedObjectModel *)mergedModels
                            studyIdentifier:(NSString *)__unused studyIdentifier
{
    self = [super init];
    if (self) {
        _dateChangeTestTimer = nil;
        _lastKnownDate = [NSDate date];
        _countOfTotalCompletedTasksForToday = 0;
        _countOfTotalCompletedTasksForToday = 0;

        [self setUpCoreDataStackWithPersistentStorePath:storePath additionalModels:mergedModels];
        [self setUpCurrentUser:self.persistentContext];
        [self setUpHealthKit];
        [self setupParameters];
        [self setupNotifications];
        [self setupNewsFeedManager];
    }
    return self;
}

- (void)setUpCurrentUser:(NSManagedObjectContext *)context
{
    if (!_currentUser) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _currentUser = [[APCUser alloc] initWithContext:context];
        });
    }
}

- (void)setupParameters
{
    self.parameters = [[APCParameters alloc] initWithFileName:@"APCParameters.json"];
    [self.parameters setDelegate:self];
}

- (void)setupNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector (appCameToForeground:)
                                                 name: UIApplicationDidFinishLaunchingNotification
                                               object: nil];

    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector (appCameToForeground:)
                                                 name: UIApplicationWillEnterForegroundNotification
                                               object: nil];

    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector (appWentToBackground:)
                                                 name: UIApplicationDidEnterBackgroundNotification
                                               object: nil];
}

- (void)setupNewsFeedManager
{
    _newsFeedManager = [[APCNewsFeedManager alloc] init];
    [_newsFeedManager fetchFeedWithCompletion:nil];
}

#pragma mark - HealthKit

- (void)setUpHealthKit
{
    self.healthStore = [HKHealthStore isHealthDataAvailable] ? [[HKHealthStore alloc] init] : nil;
}



#pragma mark - Core Data Subsystem

- (void)setUpCoreDataStackWithPersistentStorePath:(NSString *)storePath additionalModels:(NSManagedObjectModel *)mergedModels
{
    [self loadManagedObjectModel:mergedModels];
    [self initializePersistentStoreCoordinator:storePath];
    [self createManagedObjectContexts];
}

- (void)loadManagedObjectModel:(NSManagedObjectModel *)mergedModels
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    
    NSString *modelPath = [bundle pathForResource:@"APCModel" ofType:@"momd"];
    NSAssert(modelPath, @"No Model Path Found!");
    NSURL *modelURL = [NSURL fileURLWithPath:modelPath];
    NSManagedObjectModel *model = [[[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL] mutableCopy];
    if (mergedModels) {
        model = [NSManagedObjectModel modelByMergingModels:@[model, mergedModels]];
    }
    self.managedObjectModel = model;
}

- (void)initializePersistentStoreCoordinator:(NSString *)storePath
{
    self.storePath = storePath;
    self.persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    [self setUpPersistentStore];
}

- (void)setUpPersistentStore
{
    NSError *errorOpeningOrCreatingCoreDataFile = nil;
    NSURL *persistentStoreUrl = [NSURL fileURLWithPath:self.storePath];
    BOOL fileAlreadyExists = [[NSFileManager defaultManager] fileExistsAtPath:self.storePath];
    
    NSDictionary *options = @{ NSMigratePersistentStoresAutomaticallyOption : @(YES),
                               NSInferMappingModelAutomaticallyOption       : @(YES)
                               };
    
    NSPersistentStore *persistentStore = [self.persistentStoreCoordinator addPersistentStoreWithType: NSSQLiteStoreType
                                                                                       configuration: nil
                                                                                                 URL: persistentStoreUrl
                                                                                             options: options
                                                                                               error: & errorOpeningOrCreatingCoreDataFile];
    
    if (persistentStore) {
        // Great!  Everything worked.  (Sound of whistling)
    }
    else {
        /*
         In case we want to switch() on them, the list of possible
         CoreData errors is here:
         
         https://developer.apple.com/library/ios/documentation/Cocoa/Reference/CoreDataFramework/Miscellaneous/CoreData_Constants/
         */
        NSError *catastrophe = nil;
        
        if (fileAlreadyExists) {
            catastrophe = [NSError errorWithCode: kErrorCantOpenDatabase_Code
                                          domain: kCoreDataErrorDomain
                                   failureReason: kErrorCantOpenDatabase_Reason
                              recoverySuggestion: kErrorCantOpenDatabase_Suggestion
                                 relatedFilePath: self.storePath
                                      relatedURL: persistentStoreUrl
                                     nestedError: errorOpeningOrCreatingCoreDataFile];
        }
        else {
            catastrophe = [NSError errorWithCode: kErrorCantCreateDatabase_Code
                                          domain: kCoreDataErrorDomain
                                   failureReason: kErrorCantCreateDatabase_Reason
                              recoverySuggestion: kErrorCantCreateDatabase_Suggestion
                                 relatedFilePath: self.storePath
                                      relatedURL: persistentStoreUrl
                                     nestedError: errorOpeningOrCreatingCoreDataFile];
        }
        
        APCLogError2(catastrophe);
        
        
        /*
         Report this actually-catastrophic error to the app.
         It'll display it when it gets a chance -- a few
         milliseconds from now (like, thousands of actual
         instructions from now), asynchronously.
         */
        APCAppDelegate *appDelegate = (APCAppDelegate *) [[UIApplication sharedApplication] delegate];
        [appDelegate registerCatastrophicStartupError: catastrophe];
    }
}

- (void)removeSqliteStore
{
    NSError *localError;
    [[NSFileManager defaultManager] removeItemAtPath:self.storePath error:&localError];
    APCLogError2(localError);
}

- (void)createManagedObjectContexts
{
    self.persistentContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    self.persistentContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
    
    self.mainContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    self.mainContext.parentContext = self.persistentContext;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mergeChangesToMainContext:) name:NSManagedObjectContextDidSaveNotification object:self.persistentContext];
}

- (void)mergeChangesToMainContext:(NSNotification*) notification
{
    [self.mainContext performBlock:^{
        [self.mainContext mergeChangesFromContextDidSaveNotification:notification];
    }];
}


#pragma mark - Core Data Public Methods

- (void)resetCoreData
{
    //EXERCISE CAUTION IN CALLING THIS METHOD
    [self.mainContext reset];
    [self.persistentContext reset];
    NSError * error;
    NSPersistentStore * persistenStore = [self.persistentStoreCoordinator persistentStores] [0];
    [self.persistentStoreCoordinator removePersistentStore:persistenStore error:&error];
    APCLogError2 (error);
    [self removeSqliteStore];
    [self setUpPersistentStore];
    APCAppDelegate * appDelegate = [APCAppDelegate sharedAppDelegate];
    [appDelegate.scheduler loadTasksAndSchedulesFromDiskAndThenUseThisQueue: nil toDoThisWhenDone: nil];
}


#pragma mark - Core Data Helpers - ONLY RETURNS in NSManagedObjects in mainContext

- (NSFetchRequest*)requestForScheduledTasksDueFrom:(NSDate *)fromDate toDate:(NSDate *)toDate sortDescriptors:(NSArray *)sortDescriptors
{
    NSFetchRequest *request = [APCScheduledTask request];
    request.predicate = [NSPredicate predicateWithFormat:@"dueOn >= %@ and dueOn < %@", fromDate, toDate];
    request.sortDescriptors = sortDescriptors;
    return request;
}

- (NSArray *)scheduledTasksDueFrom:(NSDate *)fromDate toDate:(NSDate *)toDate sortDescriptors:(NSArray *)sortDescriptors
{
    NSError*error;
    NSArray *res = [self.mainContext executeFetchRequest:[self requestForScheduledTasksDueFrom:fromDate toDate:toDate sortDescriptors:sortDescriptors]
                                                   error:&error];
    if (res) {
        return res;
    }
    
    APCLogError(@"Failed to search for due tasks: %@", error.localizedDescription);
    return nil;
}

- (NSFetchRequest*)requestForScheduledTasksForPredicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors
{
    NSFetchRequest *request = [APCScheduledTask request];
    request.predicate = predicate;
    request.sortDescriptors = sortDescriptors;
    return request;
}

- (NSArray *)scheduledTasksForPredicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors
{
    NSError *error;
    NSArray *res = [self.mainContext executeFetchRequest:[self requestForScheduledTasksForPredicate:predicate sortDescriptors:sortDescriptors]
                                                   error:&error];
    if (res) {
        return res;
    }
    
    APCLogError(@"Failed to search for scheduled tasks: %@", error.localizedDescription);
    return nil;
}

- (void) updateCountOfTotalRequiredTasksForToday: (NSUInteger) countOfRequiredTasks
                     andTotalCompletedTasksToday: (NSUInteger) countOfCompletedTasks
{
    self.countOfTotalRequiredTasksForToday = countOfRequiredTasks;
    self.countOfTotalCompletedTasksForToday = countOfCompletedTasks;
}

// This method is deprecated. See .h file for details.
- (NSUInteger)countOfAllScheduledTasksForToday
{
    return self.countOfTotalRequiredTasksForToday;
}

// This method is deprecated. See .h file for details.
- (NSUInteger)countOfCompletedScheduledTasksForToday
{
    return self.countOfTotalCompletedTasksForToday;
}


#pragma mark - Properties & Methods meant only for Categories

- (void)parameters:(APCParameters *)__unused parameters didFailWithError:(NSError *)error
{
    NSAssert(error, @"parameters are not loaded");
}


#pragma mark - Date Change Test Timer

- (void)appCameToForeground:(NSNotification *)__unused notification
{
    APCLogDebug (@"Handling date changes (DataSubstrate): The app is back in the foreground. Restarting the date-change timer, and checking immediately for a date change.");

    [self hootAndHollerIfTheDateCrossedMidnight];
    [self startTimer];
}

- (void)appWentToBackground:(NSNotification *)__unused notification
{
    APCLogDebug (@"Handling date changes (DataSubstrate): The app has moved to the background. Cancelling the date-change timer.");

    [self stopTimer];
}

- (void)startTimer
{
    /*
     We can only stop a timer on the thread from which
     we started it.  Since this block of code is
     very small, the main thread is fine.
     */
    [[NSOperationQueue mainQueue] addOperationWithBlock: ^{

        [self stopTimerInternal];

        self.dateChangeTestTimer = [NSTimer scheduledTimerWithTimeInterval: dateCheckTimeInterval
                                                                    target: self
                                                                  selector: @selector (hootAndHollerIfTheDateCrossedMidnight)
                                                                  userInfo: nil
                                                                   repeats: YES];
    }];
}

- (void)stopTimer
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{

        [self stopTimerInternal];

    }];
}

/**
 Intended to be called only from within the above
 -startTimer and -stopTimer methods, above.
 */
- (void)stopTimerInternal
{
    if (self.dateChangeTestTimer != nil)
    {
        [self.dateChangeTestTimer invalidate];
        self.dateChangeTestTimer = nil;
    }
}

- (void)hootAndHollerIfTheDateCrossedMidnight
{
    [[NSOperationQueue mainQueue] addOperationWithBlock: ^{

        NSDate *now = [NSDate date];

        /**
         This calcluation handles the date moving both
         forward and backward, so it handles normal
         calendar-day turnovers as well as debugging
         situations.
         */
        if (! [now isSameDayAsDate: self.lastKnownDate])
        {
            APCLogDebug (@"Handling date changes (DataSubstrate): The date has changed. Sending notification.");

            self.lastKnownDate = now;

            [[NSNotificationCenter defaultCenter] postNotificationName: APCDayChangedNotification
                                                                object: nil];
        }
    }];
}

@end
