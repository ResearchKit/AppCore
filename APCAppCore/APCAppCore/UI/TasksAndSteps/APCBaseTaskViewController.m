// 
//  APCBaseTaskViewController.m 
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
 
#import "APCBaseTaskViewController.h"
#import "APCAppDelegate.h"
#import "APCAppCore.h"
#import "APCDataVerificationClient.h"
#import "APCDataVerificationServerAccessControl.h"
#import "APCDataUploader.h"

#import <objc/runtime.h>
#import <ResearchKit/ResearchKit.h>

static NSString * const kQuestionTypeKey            = @"questionType";
static NSString * const kQuestionTypeNameKey        = @"questionTypeName";
static NSString * const kTaskRunKey                 = @"taskRun";
static NSString * const kItemKey                    = @"item";
static NSString * const kAppNameKey                 = @"appName";
static NSString * const kAppVersionKey              = @"appVersion";
static NSString * const kPhoneInfoKey               = @"phoneInfo";
static NSString * const kUploadTimeKey              = @"uploadTime";
static NSString * const kFilesKey                   = @"files";
static NSString * const kFileInfoNameKey            = @"filename";
static NSString * const kFileInfoTimeStampKey       = @"timestamp";
static NSString * const kFileInfoContentTypeKey     = @"contentType";

//    ORK Result Base Class property keys
//
static NSString * const kIdentifierKey              = @"identifier";
static NSString * const kStartDateKey               = @"startDate";
static NSString * const kEndDateKey                 = @"endDate";
static NSString * const kUserInfoKey                = @"userInfo";

@interface APCBaseTaskViewController () <UIViewControllerRestoration>

@property (strong, nonatomic) ORKStepViewController *stepVC;
@property (strong, nonatomic) ORKStep *step;
@property (strong, nonatomic) NSData *localRestorationData;

@end

/**
 Converts the ORKTaskViewControllerFinishReason enum
 to a string.
 
 Declared in this file because the enum itself is
 declared in my ORK superclass, ORKTaskViewController.
 
 Contains hard-coded strings because I think is their proper
 place -- the place where there's a 1:1 mapping between
 the enum and the string equivalent.
 
 Problems:   Highly dependent on the definition of original
 enum itself.  If the enum changes, this function instantly
 starts delivering misleading strings.  Granted, I'm only
 currently using them internally, but, still.  That's why
 I'm only declaring this function inside this file, for now.
 
 Suggested Future Changes:  push this function into
 ResearchKit, making it a part of the same class or file
 where the enum itself is declared.
 
 This is a function, not a method, so that it can follow
 Apple's convention for functions which convert various
 objects to strings:  NSStringFromClassName(), etc.
 
 @return A human-readable string for the FinishReason.
 If the finishReason can't be identified -- if you pass
 a random integer, for example, or if the source enum
 definition is changed -- returns "Unknown FinishReason."
 
 @see ORKTaskViewControllerFinishReason
 */
NSString * NSStringFromORKTaskViewControllerFinishReason (ORKTaskViewControllerFinishReason reason)
{
    NSString *result = nil;

    switch (reason)
    {
        case ORKTaskViewControllerFinishReasonSaved:        result = @"Saved";                  break;
        case ORKTaskViewControllerFinishReasonCompleted:    result = @"Completed";              break;
        case ORKTaskViewControllerFinishReasonDiscarded:    result = @"Discarded";              break;
        case ORKTaskViewControllerFinishReasonFailed:       result = @"Failed";                 break;
        default:                                            result = @"Unknown FinishReason";   break;
    }

    return result;
}




@implementation APCBaseTaskViewController

#pragma  mark  -  Instance Initialisation
+ (instancetype)customTaskViewController: (APCScheduledTask*) scheduledTask
{
    [[UIView appearance] setTintColor:[UIColor appPrimaryColor]];
    
    id<ORKTask> task = [self createTask: scheduledTask];
    
    NSUUID * taskRunUUID = [NSUUID UUID];
    
    APCBaseTaskViewController * controller = task ? [[self alloc] initWithTask:task taskRunUUID:taskRunUUID] : nil;
    controller.scheduledTask = scheduledTask;
    controller.delegate = controller;
    
    return  controller;
}

+ (instancetype)configureTaskViewController:(APCTaskGroup *)taskGroup
{
    APCPotentialTask *potentialTask             = taskGroup.requiredRemainingTasks.firstObject;
    APCBaseTaskViewController *viewController   = nil;
    
    /*
     It's a fundamental business requirement that our users
     can do *more* than the required number of tasks.  This
     object lets us do that, if they've gone through all
     the actually- required tasks for this date.
     */
    if (potentialTask == nil)
    {
        potentialTask = taskGroup.samplePotentialTask;
    }
    
    if (potentialTask != nil) {
        APCScheduledTask *scheduledTask = [[APCScheduler defaultScheduler] createScheduledTaskFromPotentialTask:potentialTask];
        
        viewController = [self customTaskViewController:scheduledTask];
    }
    
    
    return viewController;
}

+ (id<ORKTask>)createTask: (APCScheduledTask*) __unused scheduledTask
{
    //To be overridden by child classes
    return  nil;
}

- (NSString *) createResultSummary
{
    //To be overridden by child classes
    return nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.canGenerateResult = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    
    if (self.outputDirectory == nil) {
        self.outputDirectory = [NSURL fileURLWithPath:self.taskResultsFilePath];
    }
    [super viewWillAppear:animated];
    APCLogViewControllerAppeared();
    APCLogEventWithData(kTaskEvent, (@{
                                       @"task_status":@"Started",
                                       @"task_title": (self.scheduledTask.task.taskTitle == nil) ? @"No Title Provided": self.scheduledTask.task.taskTitle,
                                       @"task_view_controller":NSStringFromClass([self class])
                                       }));
}

- (APCAppDelegate *) appDelegate
{
    return [APCAppDelegate sharedAppDelegate];
}


/*********************************************************************************/
#pragma mark - ORKOrderedTaskDelegate
/*********************************************************************************/

- (void) taskViewController: (ORKTaskViewController *) taskViewController
        didFinishWithReason: (ORKTaskViewControllerFinishReason) reason
                      error: (nullable NSError *) error
{
    NSString *currentStepIdentifier = self.currentStepViewController.step.identifier;
    NSString *taskTitle = self.scheduledTask.task.taskTitle;
    BOOL shouldLogError = YES;

    if (currentStepIdentifier == nil)
    {
        currentStepIdentifier = @"Step identifier not available";
    }

    if (taskTitle == nil)
    {
        taskTitle = @"Task Title not available";
    }

    /*
     Most results have common behaviors, below this
     switch() statement: log the fact that we're here, log
     an error if needed, and close the window.  For those
     with specific behaviors, add them to this switch().
     */
    switch (reason)
    {
        case ORKTaskViewControllerFinishReasonCompleted:
            
            // Only process results when the task is able to
            // generate them.
            if (self.canGenerateResult)
            {
                [self processTaskResult];
            }
            
            [self.scheduledTask completeScheduledTask];
            [[NSNotificationCenter defaultCenter]postNotificationName:APCActivityCompletionNotification object:nil];
            break;

        case ORKTaskViewControllerFinishReasonFailed:

            if ([error.domain isEqualToString: NSCocoaErrorDomain])
            {
                if (error.code == 4)
                {
                    shouldLogError = NO;
                }
                else if (error.code == 260)
                {
                    // Ignore this condition as it's due to no collected data.
                    shouldLogError = NO;
                }
                else
                {
                    // Log it and bug out, as usual.
                }
            }
            
            break;

        case ORKTaskViewControllerFinishReasonDiscarded:
            /*
             The user cancelled the operation.  Delete the ScheduledTask.

             In our new world, the theory is:  ScheduledTasks are only created
             in the database when the user actually chooses to save them.
             Unfortunately, a lot of existing code depends on ScheduledTasks
             already having been created before a view appears.  So we'll run
             with that:  save the task while the views are using it, but then
             destroy it if the user cancels.

             This should be asynchronous.  For now, it's not, so I can
             figure out what threads this class (the one you're reading
             now) is reliably using.  Then I'll fix it to be wholly-
             asynchronous.
             */
            [self.appDelegate.scheduler deleteScheduledTask: self.scheduledTask];
            break;

        case ORKTaskViewControllerFinishReasonSaved:
            // Nothing special to do.
            break;

        default:
            // We don't recognize this reason.  We'll log an event saying so,
            // but we don't have anything special to do aside from that.
            break;
    }
    
    APCLogEventWithData (kTaskEvent, (@{
                                        @"task_status"           : NSStringFromORKTaskViewControllerFinishReason (reason),
                                        @"task_title"            : taskTitle,
                                        @"task_view_controller"  : NSStringFromClass (self.class),
                                        @"task_step"             : currentStepIdentifier
                                        }));

    if (shouldLogError)
    {
        APCLogError2 (error);
    }

    [taskViewController dismissViewControllerAnimated:YES completion:nil];
}


- (NSString *)taskResultsFilePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * path = [[paths lastObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", self.taskRunUUID.UUIDString]];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSError* fileError;
        BOOL     created = [[NSFileManager defaultManager] createDirectoryAtPath:path
                                                     withIntermediateDirectories:YES
                                                                      attributes:@{ NSFileProtectionKey : NSFileProtectionCompleteUntilFirstUserAuthentication }
                                                                           error:&fileError];
        
        if (created == NO)
        {
            APCLogError2 (fileError);
        }
    }
    
    return path;
}

- (void) processTaskResult
{
    NSString * resultSummary = [self createResultSummary];
    
    [self archiveResults];
    
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), ^{
        
        [self uploadResultSummary:resultSummary];
        
    });
}

/*
 Should be overridden by subclasses with specific behavior requirements, as their specific behavior
 should not be in a superclass.
 **/
- (void) archiveResults
{
    //get a fresh archive
    self.archive = [[APCDataArchive alloc]initWithReference:self.task.identifier];
    
    __weak typeof(self) weakSelf = self;
    //add dictionaries or json data to the archive, calling completeArchive when done
    [self.result.results enumerateObjectsUsingBlock:^(ORKStepResult *stepResult, NSUInteger __unused idx, BOOL * __unused stop) {
        [stepResult.results enumerateObjectsUsingBlock:^(ORKResult *result, NSUInteger __unused idx, BOOL *__unused stop) {
            __strong typeof(self) strongSelf = weakSelf;
            //Update date if needed
            if (!result.startDate) {
                result.startDate = stepResult.startDate;
                result.endDate = stepResult.endDate;
            }
            
            //this is used in BreastCancer
            if ([result isKindOfClass:[APCDataResult class]])
            {
                APCDataResult * dataResult = (APCDataResult*) result;
                dataResult.identifier = dataResult.identifier ? : (stepResult.identifier ? : [NSUUID UUID].UUIDString);
                NSString *fileName = [dataResult.identifier stringByAppendingString:@"_data"];
                [strongSelf.archive insertJSONDataIntoArchive:dataResult.data filename:fileName];
            }
            
            else if ([result isKindOfClass:[ORKFileResult class]])
            {
                ORKFileResult * fileResult = (ORKFileResult*) result;
                NSString *translatedFilename = [ORKFileResult filenameForFileResultIdentifier:fileResult.identifier stepIdentifier:stepResult.identifier];
                if (fileResult.fileURL) {
                    [strongSelf.archive insertDataAtURLIntoArchive:fileResult.fileURL fileName:translatedFilename];
                }
            }
            
            else if ([result isKindOfClass:[ORKTappingIntervalResult class]])
            {
                ORKTappingIntervalResult  *tappingResult = (ORKTappingIntervalResult *)result;
                [self addTappingResultsToArchive:tappingResult];
            }
            
            else if ([result isKindOfClass:[ORKSpatialSpanMemoryResult class]])
            {
                ORKSpatialSpanMemoryResult  *spatialSpanMemoryResult = (ORKSpatialSpanMemoryResult *)result;
                [self addSpatialSpanMemoryResultsToArchive:spatialSpanMemoryResult];
            }
            
            
            else if ([result isKindOfClass:[ORKQuestionResult class]])
            {
                [self addResultToArchive:result];
            }
            else
            {
                APCLogError(@"Result not processed for : %@", result.identifier);
            }
        }];
    }];
}

/**
 Subclasses should override these methods
 */

- (void)addSpatialSpanMemoryResultsToArchive:(ORKSpatialSpanMemoryResult *) __unused result
{
    
}

- (void)addTappingResultsToArchive:(ORKTappingIntervalResult *)__unused result
{
    
}

#pragma mark - Upload

- (void)uploadResultSummary: (NSString *)resultSummary
{
    //Encrypt and Upload
    APCDataArchiveUploader *archiveUploader = [[APCDataArchiveUploader alloc]init];
    
    __weak typeof(self) weakSelf = self;
    [archiveUploader encryptAndUploadArchive:self.archive withCompletion:^(NSError *error) {
        __strong typeof(self) strongSelf = weakSelf;
        if (! error) {
            if (resultSummary != nil || self.createResultSummaryBlock) {
                [strongSelf storeInCoreDataWithFileName:self.archive.unencryptedURL.absoluteString.lastPathComponent resultSummary:resultSummary];
            }
        }else{
            APCLogError2(error);
        }
    }];
    
}

- (void) storeInCoreDataWithFileName: (NSString *) fileName resultSummary: (NSString *) resultSummary
{
    
    NSManagedObjectContext *context = [[APCScheduler defaultScheduler] managedObjectContext];
    
    [self storeInCoreDataWithFileName: fileName resultSummary: resultSummary usingContext: context];
}

- (void) storeInCoreDataWithFileName: (NSString *) fileName
                       resultSummary: (NSString *) resultSummary
                        usingContext: (NSManagedObjectContext *) context
{
    NSManagedObjectID * objectID = [APCResult storeTaskResult:self.result inContext:context];
    APCScheduledTask *localContextScheduledTask = (APCScheduledTask *)[context objectWithID:self.scheduledTask.objectID];
    
    APCResult * result = (APCResult*)[context objectWithID:objectID];
    result.archiveFilename = fileName;
    result.resultSummary = resultSummary;
    result.scheduledTask = localContextScheduledTask;
    
    NSError * resultSaveError = nil;
    BOOL saveSuccess = [result saveToPersistentStore:&resultSaveError];
    
    if (!saveSuccess) {
        APCLogError2 (resultSaveError);
    }
    
    [self.appDelegate.dataMonitor batchUploadDataToBridgeOnCompletion:^(NSError *error)
     {
         APCLogError2 (error);
     }];
    
    if (self.createResultSummaryBlock) {
        [self.appDelegate.dataMonitor performCoreDataBlockInBackground:self.createResultSummaryBlock];
    }
}

/*********************************************************************************/
#pragma mark - State Restoration
/*********************************************************************************/

-(void)stepViewControllerWillAppear:(ORKStepViewController *)viewController
{
    [super stepViewControllerWillAppear:viewController];
    self.localRestorationData = self.restorationData; //Cached to store during encode state
    
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [coder encodeObject:_scheduledTask.objectID.URIRepresentation.absoluteString forKey:@"scheduledTask"];
    [coder encodeObject:_localRestorationData forKey:@"restorationData"];
    [coder encodeObject:self.task forKey:@"task"];
    [super encodeRestorableStateWithCoder:coder];
}

+ (UIViewController *) viewControllerWithRestorationIdentifierPath: (NSArray *) __unused identifierComponents
                                                             coder: (NSCoder *) coder
{
    id<ORKTask> task = [coder decodeObjectForKey:@"task"];
    NSString * scheduledTaskID = [coder decodeObjectForKey:@"scheduledTask"];
    APCAppDelegate *appDelegate = [APCAppDelegate sharedAppDelegate];
    NSManagedObjectID * objID = [appDelegate.dataSubstrate.persistentStoreCoordinator managedObjectIDForURIRepresentation:[NSURL URLWithString:scheduledTaskID]];
    APCScheduledTask * scheduledTask = (APCScheduledTask*)[appDelegate.dataSubstrate.mainContext objectWithID:objID];
    id localRestorationData = [coder decodeObjectForKey:@"restorationData"];
    if (scheduledTask) {
        APCBaseTaskViewController * tvc =[[self alloc] initWithTask:task restorationData:localRestorationData];
        tvc.scheduledTask = scheduledTask;
        tvc.restorationIdentifier = [task identifier];
        tvc.restorationClass = self;
        
        tvc.delegate = tvc;
        return tvc;
    }
    return nil;
}

#pragma mark - Utilities

- (void) addResultToArchive: (ORKResult*) result
{
    NSMutableArray * propertyNames = [NSMutableArray array];
    
    /*
     Get the names of all properties of our result's class
     and all its superclasses.  Stop when we hit ORKResult.
     */
    Class klass = result.class;
    BOOL done = NO;
    NSArray *propertyNamesForOneClass = nil;
    
    while (klass != nil && ! done)
    {
        propertyNamesForOneClass = [self classPropsFor: klass];
        
        [propertyNames addObjectsFromArray: propertyNamesForOneClass];
        
        if (klass == [ORKResult class])
        {
            done = YES;
        }
        else
        {
            klass = [klass superclass];
        }
    }
    
    NSDictionary *propertiesToSave = [result dictionaryWithValuesForKeys: propertyNames];
    NSDictionary *serializableData = [APCJSONSerializer serializableDictionaryFromSourceDictionary: propertiesToSave];
    
    APCLogDebug(@"%@", serializableData);
    
    NSString *filename = [result.identifier stringByAppendingString:@".json"];
    [self.archive insertIntoArchive:serializableData filename:filename];
}

- (NSArray *)classPropsFor:(Class)klass
{
    if (klass == NULL) {
        return nil;
    }
    
    NSMutableArray *results = [NSMutableArray array];
    
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList(klass, &outCount);
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        const char *propName = property_getName(property);
        if(propName) {
            NSString *propertyName = [NSString stringWithUTF8String:propName];
            [results addObject:propertyName];
        }
    }
    free(properties);
    
    return [NSArray arrayWithArray:results];
}

@end
