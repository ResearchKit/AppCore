// 
//  APCBaseTaskViewController.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "APCBaseTaskViewController.h"
#import "APCAppDelegate.h"
#import "APCAppCore.h"

@implementation APCBaseTaskViewController

#pragma  mark  -  Instance Initialisation
+ (instancetype)customTaskViewController: (APCScheduledTask*) scheduledTask
{
    id<RKSTTask> task = [self createTask: scheduledTask];
    NSUUID * taskRunUUID = [NSUUID UUID];
    APCBaseTaskViewController * controller = task ? [[self alloc] initWithTask:task taskRunUUID:taskRunUUID] : nil;
    controller.scheduledTask = scheduledTask;
    controller.delegate = controller;
    return  controller;
}

+ (id<RKSTTask>)createTask: (APCScheduledTask*) scheduledTask
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
    self.showsProgressInNavigationBar = NO;
    
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
#pragma mark - RKSTOrderedTaskDelegate
/*********************************************************************************/
- (void)taskViewControllerDidComplete: (RKSTTaskViewController *)taskViewController
{
    [self processTaskResult];
    
    [self.scheduledTask completeScheduledTask];
    APCAppDelegate * appDelegate = (APCAppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate.scheduler updateScheduledTasksIfNotUpdating:NO];
    [taskViewController dismissViewControllerAnimated:YES completion:nil];
    APCLogEventWithData(kTaskEvent, (@{
                                       @"task_status":@"Completed",
                                       @"task_title": self.scheduledTask.task.taskTitle,
                                       @"task_view_controller":NSStringFromClass([self class])
                                       }));
}

- (void)taskViewControllerDidCancel:(RKSTTaskViewController *)taskViewController
{
    [taskViewController dismissViewControllerAnimated:YES completion:nil];
    APCLogEventWithData(kTaskEvent, (@{
                                       @"task_status":@"Cancelled",
                                       @"task Title": self.scheduledTask.task.taskTitle,
                                       @"task_view_controller":NSStringFromClass([self class])
                                       }));
}

- (void)taskViewController:(RKSTTaskViewController *)taskViewController didFailOnStep:(RKSTStep *)step withError:(NSError *)error
{
    APCLogError2 (error);
    APCLogEventWithData(kTaskEvent, (@{
                                       @"task_status":@"Failed",
                                       @"task Title": self.scheduledTask.task.taskTitle,
                                       @"task_view_controller":NSStringFromClass([self class])
                                       }));
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
//    NSString * resultSummary = [self createResultSummary];
//    NSString * archiveFileName = nil;//[self.result archiveWithFilePath:self.taskResultsFilePath];
//    [self storeInCoreDataWithFileName:archiveFileName resultSummary:resultSummary];
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

@end
