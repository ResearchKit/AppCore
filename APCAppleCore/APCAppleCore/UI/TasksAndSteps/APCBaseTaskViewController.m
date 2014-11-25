//
//  APHSetupTaskViewController.m
//  Parkinson
//
//  Created by Henry McGilton on 9/3/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCBaseTaskViewController.h"
#import "APCAppDelegate.h"
#import "APCAppleCore.h"
#import "RKSTTaskResult+Archiver.h"

@implementation APCBaseTaskViewController

#pragma  mark  -  Instance Initialisation
+ (instancetype)customTaskViewController: (APCScheduledTask*) scheduledTask
{
    RKSTOrderedTask  *task = [self createTask: scheduledTask];
    NSUUID * taskRunUUID = [NSUUID UUID];
    APCBaseTaskViewController * controller = task ? [[self alloc] initWithTask:task taskRunUUID:taskRunUUID] : nil;
    controller.scheduledTask = scheduledTask;
    controller.taskDelegate = controller;
    return  controller;
}

+ (RKSTOrderedTask *)createTask: (APCScheduledTask*) scheduledTask
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
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.taskResultsFilePath]) {
        NSError * fileError;
        [[NSFileManager defaultManager] createDirectoryAtPath:self.taskResultsFilePath withIntermediateDirectories:YES attributes:nil error:&fileError];
        [fileError handle];
    }
    
    if (self.outputDirectory) {
        self.outputDirectory = [NSURL fileURLWithPath:self.taskResultsFilePath];
    }
    [super viewWillAppear:animated];
}
/*********************************************************************************/
#pragma mark - RKSTOrderedTaskDelegate
/*********************************************************************************/
- (void)taskViewControllerDidComplete: (RKSTTaskViewController *)taskViewController
{
    [self processTaskResult];
    
    [self.scheduledTask completeScheduledTask];
    [taskViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)taskViewControllerDidCancel:(RKSTTaskViewController *)taskViewController
{
    [taskViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)taskViewController:(RKSTTaskViewController *)taskViewController didFailOnStep:(RKSTStep *)step withError:(NSError *)error
{
    [error handle];
}

- (NSString *)taskResultsFilePath
{

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * path = [[paths lastObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", self.taskRunUUID.UUIDString]];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSError * fileError;
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&fileError];
        [fileError handle];
    }
    
    return path;
}

- (void) processTaskResult
{
    NSString * resultSummary = [self createResultSummary];
    NSString * archiveFileName = [self.result archiveWithFilePath:self.taskResultsFilePath];
    [self storeInCoreDataWithFileName:archiveFileName resultSummary:resultSummary];
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
    [error handle];
    [result uploadToBridgeOnCompletion:^(NSError *error) {
        [error handle];
        if (!error) {
            NSLog(@"DataArchive uploaded For Task: \"%@\"  RunID: \"%@\"", self.task.identifier, self.taskRunUUID.UUIDString);
        }
    }];
}

@end
