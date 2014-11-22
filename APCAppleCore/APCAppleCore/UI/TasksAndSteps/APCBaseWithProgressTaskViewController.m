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
static NSString *const kFinishedProperty = @"finished";

@interface APCBaseWithProgressTaskViewController ()
@property  (nonatomic, weak)  APCStepProgressBar  *progressor;
@end

@implementation APCBaseWithProgressTaskViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    CGRect  navigationBarFrame = self.navigationBar.frame;
    CGRect  progressorFrame = CGRectMake(0.0, CGRectGetHeight(navigationBarFrame) - kAPCStepProgressBarHeight, CGRectGetWidth(navigationBarFrame), kAPCStepProgressBarHeight);
    
    APCStepProgressBar  *tempProgressor = [[APCStepProgressBar alloc] initWithFrame:progressorFrame style:APCStepProgressBarStyleOnlyProgressView];
    
    RKSTOrderedTask * task = (RKSTOrderedTask*) self.task;
    NSArray  *steps = task.steps;
    tempProgressor.numberOfSteps = [steps count];
    [tempProgressor setCompletedSteps: 1 animation:NO];
    tempProgressor.progressTintColor = [UIColor appTertiaryColor1];
    [self.navigationBar addSubview:tempProgressor];
    self.progressor = tempProgressor;
    
    self.showsProgressInNavigationBar = NO;
    self.navigationBar.topItem.title = NSLocalizedString(self.taskName, nil);
}

- (NSString *)taskName
{
    return self.scheduledTask.task.taskTitle;
}

/*********************************************************************************/
#pragma mark - StepViewController Delegate Methods
/*********************************************************************************/

- (void)stepViewControllerDidFinish:(RKSTStepViewController *)stepViewController navigationDirection:(RKSTStepViewControllerNavigationDirection)direction
{
    [super stepViewControllerDidFinish:stepViewController navigationDirection:direction];
    
    NSInteger  completedSteps = self.progressor.completedSteps;
    if (direction == RKSTStepViewControllerNavigationDirectionForward) {
        completedSteps = completedSteps + 1;
    } else {
        completedSteps = completedSteps - 1;
    }
    [self.progressor setCompletedSteps:completedSteps animation:YES];
}


- (void)taskViewController:(RKSTTaskViewController *)taskViewController stepViewControllerWillAppear:(RKSTStepViewController *)stepViewController
{
    if ([stepViewController isKindOfClass:[RKSTActiveStepViewController class]] && [self advanceArrayContainsStep:stepViewController.step])
    {
        [stepViewController addObserver:self forKeyPath:kFinishedProperty options:NSKeyValueObservingOptionNew context:NULL];
    }
}

- (BOOL) advanceArrayContainsStep: (RKSTStep*) step
{
    __block BOOL retValue = NO;
    [self.stepsToAutomaticallyAdvanceOnTimer enumerateObjectsUsingBlock:^(NSString* stepID, NSUInteger idx, BOOL *stop) {
        if([step.identifier isEqualToString:stepID])
        {
            retValue = YES;
        }
    }];
    return retValue;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:kFinishedProperty]) {
        if ([object isFinished]) {
            RKSTStepViewController * vc = object;
            [vc.delegate stepViewControllerDidFinish:vc navigationDirection:RKSTStepViewControllerNavigationDirectionForward];
            @try {
                [object removeObserver:self forKeyPath:kFinishedProperty];
            }
            @catch (NSException * __unused exception) {}
        }
    }
}

@end
