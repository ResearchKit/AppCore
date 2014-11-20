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
    APCBaseTaskViewController * controller = task ? [[self alloc] initWithTask:task taskRunUUID:[NSUUID UUID]] : nil;
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.outputDirectory = [NSURL fileURLWithPath:self.taskResultsFilePath];
}
/*********************************************************************************/
#pragma mark - RKSTOrderedTaskDelegate
/*********************************************************************************/
- (void)taskViewControllerDidComplete: (RKSTTaskViewController *)taskViewController
{
    [self processTaskResult];
    
    NSError * saveError;
    self.scheduledTask.completed = @YES;
    [self.scheduledTask saveToPersistentStore:&saveError];
    [saveError handle];
    [taskViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)taskViewControllerDidCancel:(RKSTTaskViewController *)taskViewController
{
    [taskViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)taskViewController:(RKSTTaskViewController *)taskViewController didFailOnStep:(RKSTStep *)step withError:(NSError *)error
{
    [error handle];
    [taskViewController dismissViewControllerAnimated:YES completion:nil];
}

- (NSString *)taskResultsFilePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [[paths lastObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", self.taskRunUUID.UUIDString]];
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
    result.scheduledTask = self.scheduledTask;
}

@end
