//
//  APHSetupTaskViewController.h
//  Parkinson
//
//  Created by Henry McGilton on 9/3/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ResearchKit/ResearchKit.h>
#import "APCScheduledTask.h"

@interface APCBaseTaskViewController : RKSTTaskViewController <RKSTTaskViewControllerDelegate, RKSTStepViewControllerDelegate>

@property  (nonatomic, strong)  APCScheduledTask  *scheduledTask;
@property (nonatomic, readonly) NSString * taskResultsFilePath;

+ (instancetype)customTaskViewController: (APCScheduledTask*) scheduledTask;

@end
