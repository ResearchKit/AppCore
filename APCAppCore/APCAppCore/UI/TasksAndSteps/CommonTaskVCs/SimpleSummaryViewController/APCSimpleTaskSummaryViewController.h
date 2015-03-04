// 
//  APCSimpleTaskSummaryViewController.h 
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//
 
#import "APCStepViewController.h"
#import <UIKit/UIKit.h>

@interface APCSimpleTaskSummaryViewController : APCStepViewController

@property (nonatomic) CGFloat taskProgress;
@property (weak, nonatomic) IBOutlet UILabel *youCanCompareMessage;

@end
