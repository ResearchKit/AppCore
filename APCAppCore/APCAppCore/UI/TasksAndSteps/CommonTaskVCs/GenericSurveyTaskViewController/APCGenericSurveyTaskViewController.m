// 
//  APCGenericSurveyTaskViewController.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "APCGenericSurveyTaskViewController.h"

@implementation APCGenericSurveyTaskViewController

+ (RKSTOrderedTask *)createTask:(APCScheduledTask*) scheduledTask
{
    return  [scheduledTask.task rkTask];
}

@end
