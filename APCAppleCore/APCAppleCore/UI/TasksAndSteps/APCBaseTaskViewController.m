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
    return  nil;
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
    //Archive
    RKSTDataArchive * archive = [[RKSTDataArchive alloc] initWithItemIdentifier:self.task.identifier
                                                                studyIdentifier:((APCAppDelegate*)[UIApplication sharedApplication].delegate).defaultInitializationOptions[kStudyIdentifierKey]
                                                                    taskRunUUID:self.taskRunUUID
                                                                  extraMetadata:nil
                                                                 fileProtection:RKFileProtectionCompleteUnlessOpen];
    
    NSArray * array = self.result.results;
    [array enumerateObjectsUsingBlock:^(RKSTStepResult *stepResult, NSUInteger idx, BOOL *stop) {
        [stepResult.results enumerateObjectsUsingBlock:^(RKSTResult *result, NSUInteger idx, BOOL *stop) {
            NSError * archiveError;
            [result addToArchive:archive error:&archiveError];
            [archiveError handle];
        }];
    }];
    NSError * archiveError;
    [archiveError handle];
    NSURL * url = [archive archiveURLWithError:&archiveError];
    NSLog(@"URL for archive: %@", url);
    
    //Store in CoreData
    APCResult * apcResult = [APCResult storeRKSTResult:self.result inContext:((APCAppDelegate *)[UIApplication sharedApplication].delegate).dataSubstrate.mainContext];
    apcResult.scheduledTask = self.scheduledTask;
    NSError * saveError;
    [apcResult saveToPersistentStore:&saveError];
    [saveError handle];
}

@end
