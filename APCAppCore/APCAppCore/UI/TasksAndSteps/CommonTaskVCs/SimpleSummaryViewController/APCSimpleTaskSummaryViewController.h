// 
//  APCSimpleTaskSummaryViewController.h 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "APCStepViewController.h"
#import <UIKit/UIKit.h>

@interface APCSimpleTaskSummaryViewController : APCStepViewController

@property (nonatomic) CGFloat taskProgress;
@property (weak, nonatomic) IBOutlet UILabel *youCanCompareMessage;

@end
