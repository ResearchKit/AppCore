//
//  APCGenericSurveyTaskViewController.m
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 10/22/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCGenericSurveyTaskViewController.h"

@implementation APCGenericSurveyTaskViewController

+ (RKSTOrderedTask *)createTask: (APCScheduledTask*) scheduledTask
{
    RKSTOrderedTask * task = [scheduledTask.task rkTask];
    return  task;
}

@end
