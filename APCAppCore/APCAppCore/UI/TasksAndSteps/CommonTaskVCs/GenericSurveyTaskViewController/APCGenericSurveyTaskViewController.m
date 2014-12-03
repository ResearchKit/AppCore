//
//  APCGenericSurveyTaskViewController.m
//  APCAppCore
//
//  Created by Dhanush Balachandran on 11/26/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCGenericSurveyTaskViewController.h"

@implementation APCGenericSurveyTaskViewController

+ (RKSTOrderedTask *)createTask:(APCScheduledTask*) scheduledTask
{
    return  [scheduledTask.task rkTask];
}

@end
