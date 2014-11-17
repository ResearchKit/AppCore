//
//  APCBaseWithProgressTaskViewController.m
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 11/10/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCBaseWithProgressTaskViewController.h"
#import "APCAppleCore.h"

static  CGFloat  kAPCStepProgressBarHeight = 8.0;

@interface APCBaseWithProgressTaskViewController ()
@property  (nonatomic, weak)  APCStepProgressBar  *progressor;
@end

@implementation APCBaseWithProgressTaskViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect  navigationBarFrame = self.navigationBar.frame;
    CGRect  progressorFrame = CGRectMake(0.0, CGRectGetHeight(navigationBarFrame) - kAPCStepProgressBarHeight, CGRectGetWidth(navigationBarFrame), kAPCStepProgressBarHeight);
    
    APCStepProgressBar  *tempProgressor = [[APCStepProgressBar alloc] initWithFrame:progressorFrame style:APCStepProgressBarStyleOnlyProgressView];
    
    RKTask * task = (RKTask*) self.task;
    NSArray  *steps = task.steps;
    tempProgressor.numberOfSteps = [steps count];
    [tempProgressor setCompletedSteps: 1 animation:NO];
    tempProgressor.progressTintColor = [UIColor appTertiaryColor1];
    [self.navigationBar addSubview:tempProgressor];
    self.progressor = tempProgressor;
    
    self.showsProgressInNavigationBar = NO;
    self.navigationBar.topItem.title = NSLocalizedString(self.task.name, nil);
}

/*********************************************************************************/
#pragma mark - StepViewController Delegate Methods
/*********************************************************************************/

- (void)stepViewControllerDidFinish:(RKStepViewController *)stepViewController navigationDirection:(RKStepViewControllerNavigationDirection)direction
{
    [super stepViewControllerDidFinish:stepViewController navigationDirection:direction];
    
    NSInteger  completedSteps = self.progressor.completedSteps;
    if (direction == RKStepViewControllerNavigationDirectionForward) {
        completedSteps = completedSteps + 1;
    } else {
        completedSteps = completedSteps - 1;
    }
    [self.progressor setCompletedSteps:completedSteps animation:YES];
}

@end
