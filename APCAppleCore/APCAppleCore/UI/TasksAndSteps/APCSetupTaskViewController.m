//
//  APHSetupTaskViewController.m
//  Parkinson
//
//  Created by Henry McGilton on 9/3/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCSetupTaskViewController.h"
#import "APCAppDelegate.h"
#import "APCAppleCore.h"

@implementation APCSetupTaskViewController

#pragma  mark  -  Instance Initialisation
+ (instancetype)customTaskViewController: (APCScheduledTask*) scheduledTask
{
    RKSTOrderedTask  *task = [self createTask: scheduledTask];
    APCSetupTaskViewController * controller = task ? [[self alloc] initWithTask:task taskRunUUID:[NSUUID UUID]] : nil;
    controller.scheduledTask = scheduledTask;
    controller.taskDelegate = controller;
    return  controller;
}

+ (RKSTOrderedTask *)createTask: (APCScheduledTask*) scheduledTask
{
    return  nil;
}

/*********************************************************************************/
#pragma mark - RKSTStepViewControllerDelegate
/*********************************************************************************/
//TODO this is commented out because it prevents us from using the delegate method to navigate steps. This is also a required protocol and therefore is causing the compiler to throw a warning.

//- (void)stepViewControllerDidFinish:(RKSTStepViewController *)stepViewController navigationDirection:(RKSTStepViewControllerNavigationDirection)direction {
//    
//}

/*********************************************************************************/
#pragma mark - RKSTTaskDelegate
/*********************************************************************************/
- (void)taskViewControllerDidComplete: (RKSTTaskViewController *)taskViewController
{
    self.scheduledTask.completed = @YES;
    NSError * saveError;
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
    [taskViewController dismissViewControllerAnimated:YES completion:nil];
}

//Universal Did Produce Result
- (void)taskViewController:(RKSTTaskViewController *)taskViewController didProduceResult:(RKSTResult *)result
{
    APCResult * apcResult = [APCResult storeRKSTResult:result inContext:((APCAppDelegate *)[UIApplication sharedApplication].delegate).dataSubstrate.mainContext];
    apcResult.scheduledTask = self.scheduledTask;
    NSError * saveError;
    [apcResult saveToPersistentStore:&saveError];
    [saveError handle];
}

- (NSString *)filePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [[paths lastObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", [NSUUID UUID].UUIDString]];
}

@end
