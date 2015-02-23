// 
//  APCBaseTaskViewController.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "APCBaseTaskViewController.h"
#import "APCAppDelegate.h"
#import "APCAppCore.h"
#import "APCDataVerificationClient.h"

@interface APCBaseTaskViewController () <UIViewControllerRestoration>
@property (strong, nonatomic) ORKStepViewController * stepVC;
@property (nonatomic, strong) ORKStep * step;
@property (nonatomic, strong) NSData * localRestorationData;
@end

@implementation APCBaseTaskViewController

#pragma  mark  -  Instance Initialisation
+ (instancetype)customTaskViewController: (APCScheduledTask*) scheduledTask
{
    id<ORKTask> task = [self createTask: scheduledTask];
    NSUUID * taskRunUUID = [NSUUID UUID];
    APCBaseTaskViewController * controller = task ? [[self alloc] initWithTask:task taskRunUUID:taskRunUUID] : nil;
    controller.restorationIdentifier = [task identifier];
    controller.restorationClass = self;
    controller.scheduledTask = scheduledTask;
    controller.delegate = controller;
    return  controller;
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

- (void)viewWillAppear:(BOOL)animated
{
    
    if (self.outputDirectory == nil) {
        self.outputDirectory = [NSURL fileURLWithPath:self.taskResultsFilePath];
    }
    [super viewWillAppear:animated];
    APCLogViewControllerAppeared();
    APCLogEventWithData(kTaskEvent, (@{
                                       @"task_status":@"Started",
                                       @"task_title": self.scheduledTask.task.taskTitle,
                                       @"task_view_controller":NSStringFromClass([self class])
                                       }));
}
/*********************************************************************************/
#pragma mark - ORKOrderedTaskDelegate
/*********************************************************************************/
- (void)taskViewController:(ORKTaskViewController *)taskViewController didFinishWithResult:(ORKTaskViewControllerResult)result error:(NSError *)error
{
    if (result == ORKTaskViewControllerResultCompleted)
    {
        [self processTaskResult];
        
        [self.scheduledTask completeScheduledTask];
        APCAppDelegate* appDelegate = (APCAppDelegate*)[UIApplication sharedApplication].delegate;
        [appDelegate.scheduler updateScheduledTasksIfNotUpdating:NO];
        APCLogEventWithData(kTaskEvent, (@{
                                           @"task_status":@"ResultCompleted",
                                           @"task_title": self.scheduledTask.task.taskTitle,
                                           @"task_view_controller":NSStringFromClass([self class])
                                           }));
    }
    else if (result == ORKTaskViewControllerResultFailed)
    {
        APCLogEventWithData(kTaskEvent, (@{
                                           @"task_status":@"ResultFailed",
                                           @"task_title": self.scheduledTask.task.taskTitle,
                                           @"task_view_controller":NSStringFromClass([self class])
                                           }));
    }
    else if (result == ORKTaskViewControllerResultDiscarded)
    {
        APCLogEventWithData(kTaskEvent, (@{
                                           @"task_status":@"ResultDiscarded",
                                           @"task_title": self.scheduledTask.task.taskTitle,
                                           @"task_view_controller":NSStringFromClass([self class])
                                           }));
    }
    else if (result == ORKTaskViewControllerResultSaved)
    {
        APCLogEventWithData(kTaskEvent, (@{
                                           @"task_status":@"ResultSaved",
                                           @"task_title": self.scheduledTask.task.taskTitle,
                                           @"task_view_controller":NSStringFromClass([self class])
                                           }));
    }

    [taskViewController dismissViewControllerAnimated:YES completion:nil];
}


- (NSString *)taskResultsFilePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * path = [[paths lastObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", self.taskRunUUID.UUIDString]];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSError * fileError;
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&fileError];
        APCLogError2 (fileError);
    }
    
    return path;
}

- (void) processTaskResult
{
    NSString * resultSummary = [self createResultSummary];
    APCDataArchiver * archiver = [[APCDataArchiver alloc] initWithTaskResult:self.result];

	/*
	 See comment at bottom of this method.
	 */
	#ifdef USE_DATA_VERIFICATION_CLIENT

		archiver.preserveUnencryptedFile = YES;

	#endif


    NSString * archiveFileName = [archiver writeToOutputDirectory:self.taskResultsFilePath];
    [self storeInCoreDataWithFileName:archiveFileName resultSummary:resultSummary];

	
	/*
	 This will COPY the unencrypted file to a local
	 server.  (The code above here uploads it to Sage.)
	 We're #if-ing it to make sure this code isn't
	 accessible to Bad Guys in production.  Even if
	 the code called, if it's in RAM at all, it can
	 be exploited.
	 */
	#ifdef USE_DATA_VERIFICATION_CLIENT

		[APCDataVerificationClient uploadDataFromFileAtPath: archiver.unencryptedFilePath];

	#endif
}

- (void) storeInCoreDataWithFileName: (NSString *) fileName resultSummary: (NSString *) resultSummary
{
    NSManagedObjectContext * context = ((APCAppDelegate *)[UIApplication sharedApplication].delegate).dataSubstrate.mainContext;
    NSManagedObjectID * objectID = [APCResult storeTaskResult:self.result inContext:context];
    APCResult * result = (APCResult*)[context objectWithID:objectID];
    result.archiveFilename = fileName;
    result.resultSummary = resultSummary;
    result.scheduledTask = self.scheduledTask;
    NSError * error;
    [result saveToPersistentStore:&error];
    APCLogError2 (error);
    APCAppDelegate * appDelegate = (APCAppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate.dataMonitor batchUploadDataToBridgeOnCompletion:^(NSError *error) {
        APCLogError2 (error);
    }];
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
    NSManagedObjectID * objID = [((APCAppDelegate*)[UIApplication sharedApplication].delegate).dataSubstrate.persistentStoreCoordinator managedObjectIDForURIRepresentation:[NSURL URLWithString:scheduledTaskID]];
    APCScheduledTask * scheduledTask = (APCScheduledTask*)[((APCAppDelegate*)[UIApplication sharedApplication].delegate).dataSubstrate.mainContext objectWithID:objID];
    id localRestorationData = [coder decodeObjectForKey:@"restorationData"];
    if (scheduledTask) {
        APCBaseTaskViewController * tvc =[[self alloc] initWithTask:task restorationData:localRestorationData];
//        APCBaseTaskViewController * tvc = [[self alloc] initWithTask:task taskRunUUID:taskRunUUID];
        tvc.scheduledTask = scheduledTask;
        tvc.restorationIdentifier = [task identifier];
        tvc.restorationClass = self;

        tvc.delegate = tvc;
        return tvc;
    }
    return nil;
}

@end
