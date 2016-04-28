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
#import "APCTaskResultArchiver.h"


#import <ResearchKit/ResearchKit.h>

// Upload constants
static NSInteger        kDefaultSchemaRevision      = 1;

@interface APCBaseTaskViewController () <UIViewControllerRestoration>

@property (strong, nonatomic) ORKStepViewController *stepVC;
@property (strong, nonatomic) ORKStep *step;
@property (strong, nonatomic) NSData *localRestorationData;

/*
 * This date is updated every time a new step view controller appears
 * It was originally created to log the correct date when a task was physically competed, 
 * instead of when the user taps "done" on the completed screen
 */
@property (strong, nonatomic) NSDate* lastStepViewControllerAppearedDate;

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
+ (instancetype)customTaskViewController: (APCTask*) scheduledTask
{
    [[UIView appearance] setTintColor:[UIColor appPrimaryColor]];
    
    id<ORKTask> orkTask = [self createOrkTask: scheduledTask];
    
    NSUUID * taskRunUUID = [NSUUID UUID];
    
    APCBaseTaskViewController * controller = orkTask ? [[self alloc] initWithTask:orkTask taskRunUUID:taskRunUUID] : nil;
    controller.scheduledTask = scheduledTask;
    controller.delegate = controller;
    [controller updateSchemaRevision];
    [[APCScheduler defaultScheduler] startTask:scheduledTask];
    
    return  controller;
}

+ (instancetype)configureTaskViewController:(APCTaskGroup *)taskGroup
{
    APCTask *nextTask = nil;
    APCBaseTaskViewController *viewController   = nil;
    
    if (taskGroup.requiredRemainingTasks.count > 0) {
        nextTask = [taskGroup.requiredRemainingTasks firstObject];
    } else if (taskGroup.requiredCompletedTasks.count > 0) {
        // Allow the user to complete a required task again, essentially a gratuitous task
        nextTask = [taskGroup.requiredCompletedTasks lastObject];
    } else {
        nextTask = taskGroup.task;
    }
    
    viewController = [self customTaskViewController:nextTask];
    
    return viewController;
}

+ (id<ORKTask>)createOrkTask: (APCTask*) __unused scheduledTask
{
    //To be overridden by child classes
    return  nil;
}

- (NSString *) createResultSummary
{
    //To be overridden by child classes
    return nil;
}

- (void) updateSchemaRevision
{
    // To be overridden by child classes for non default schema revision #s
    if (self.scheduledTask) {
        self.scheduledTask.taskSchemaRevision = [NSNumber numberWithInteger:kDefaultSchemaRevision];
    }
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
                                       @"task_title": (self.scheduledTask.taskTitle == nil) ? @"No Title Provided": self.scheduledTask.taskTitle,
                                       @"task_view_controller":NSStringFromClass([self class])
                                       }));
}

- (APCAppDelegate *) appDelegate
{
    return [APCAppDelegate sharedAppDelegate];
}

- (APCTaskResultArchiver *)taskResultArchiver
{
    if (_taskResultArchiver == nil) {
        _taskResultArchiver = [[APCTaskResultArchiver alloc] init];
    }
    return _taskResultArchiver;
}


/*********************************************************************************/
#pragma mark - ORKOrderedTaskDelegate
/*********************************************************************************/

- (void) taskViewController: (ORKTaskViewController *) taskViewController
        didFinishWithReason: (ORKTaskViewControllerFinishReason) reason
                      error: (nullable NSError *) error
{
    NSString *currentStepIdentifier = self.currentStepViewController.step.identifier;
    NSString *taskTitle = self.scheduledTask.taskTitle;
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
            
            // Per BRIDGE-977, the current date at this point in the code is when the user taps "done"
            // But, we want when the user actually finished the task, which is when the "done" screen appeared
            [[APCScheduler defaultScheduler] finishTask:self.scheduledTask
                                     withCompletionDate:self.lastStepViewControllerAppearedDate];
            
            [self apiUpdateTask:self.scheduledTask];
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
            [[APCScheduler defaultScheduler] abortTask:self.scheduledTask];
            break;

        case ORKTaskViewControllerFinishReasonSaved:
            [[APCScheduler defaultScheduler] startTask:self.scheduledTask];
            [self apiUpdateTask:self.scheduledTask];
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
    // get a fresh archive
    // Note: by current design this is UI blocking if run on main thread. TODO: move off main thread? syoung 12/11/2015
    self.archive = [[APCDataArchive alloc] initWithReference:self.task.identifier task:self.scheduledTask];
    [self.taskResultArchiver appendArchive:self.archive withTaskResult:self.result];
}

- (APCSignUpPermissionsType)requiredPermission
{
    return kAPCSignUpPermissionsTypeNone;
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
    APCTask *localContextScheduledTask = (APCTask *)[context objectWithID:self.scheduledTask.objectID];
    
    APCResult * result = (APCResult*)[context objectWithID:objectID];
    result.archiveFilename = fileName;
    result.resultSummary = resultSummary;
    result.task = localContextScheduledTask;
    
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

- (void) apiUpdateTask: (APCTask *) task {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [task updateTaskOnCompletion: ^(NSError *error) {
            APCLogError2 (error);
        }];
    });
}

/*********************************************************************************/
#pragma mark - State Restoration
/*********************************************************************************/

-(void)stepViewControllerWillAppear:(ORKStepViewController *)viewController
{
    [super stepViewControllerWillAppear:viewController];
    self.localRestorationData = self.restorationData; //Cached to store during encode state
    self.lastStepViewControllerAppearedDate = [NSDate date];
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
    APCTask * scheduledTask = (APCTask*)[appDelegate.dataSubstrate.mainContext objectWithID:objID];
    id localRestorationData = [coder decodeObjectForKey:@"restorationData"];
    if (scheduledTask) {
        APCBaseTaskViewController * tvc =[[self alloc] initWithTask:task restorationData:localRestorationData delegate:nil];
        tvc.delegate = tvc;
        tvc.scheduledTask = scheduledTask;
        tvc.restorationIdentifier = [task identifier];
        tvc.restorationClass = self;
        
        tvc.delegate = tvc;
        return tvc;
    }
    return nil;
}

#pragma mark - Utilities





@end
