//
//  APHSetupTaskViewController.h
//  Parkinson
//
//  Created by Henry McGilton on 9/3/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ResearchKit/ResearchKit.h>
#import "APCAppleCore.h"
#import "APCScheduledTask.h"

@interface APCSetupTaskViewController : RKTaskViewController <RKTaskViewControllerDelegate, RKStepViewControllerDelegate>

@property  (nonatomic, strong)  APCScheduledTask  *scheduledTask;

+ (instancetype)customTaskViewController: (APCScheduledTask*) scheduledTask;

@end
