//
//  APHStepViewController.m
//  Parkinson
//
//  Created by Henry McGilton on 9/16/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCStepViewController.h"
#import "APCAppleCore.h"

@interface APCStepViewController ()

@end

@implementation APCStepViewController

- (NSString *)resultDirectoryPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * taskResultPath = [[paths lastObject] stringByAppendingPathComponent:self.taskViewController.taskRunUUID.UUIDString];
    NSString * stepResultPath = [taskResultPath stringByAppendingPathComponent:self.step.identifier];
    return stepResultPath;
}

@end
