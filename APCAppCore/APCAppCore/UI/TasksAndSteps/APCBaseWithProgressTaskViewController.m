// 
//  APCBaseWithProgressTaskViewController.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "APCBaseWithProgressTaskViewController.h"
#import "APCAppCore.h"

static  CGFloat  kAPCStepProgressBarHeight = 8.0;
static NSString *const kFinishedProperty = @"finished";

@interface APCBaseWithProgressTaskViewController ()
@property  (nonatomic, weak)  APCStepProgressBar  *progressor;
@property  (nonatomic, weak)  RKSTStepViewController * observedVC;
@end

@implementation APCBaseWithProgressTaskViewController

/*********************************************************************************/
#pragma mark - StepViewController Delegate Methods
/*********************************************************************************/

- (void)stepViewController:(RKSTStepViewController *)stepViewController didFinishWithNavigationDirection:(RKSTStepViewControllerNavigationDirection)direction
{
    if ([super respondsToSelector:@selector(stepViewController:didFinishWithNavigationDirection:)]) {
        [super stepViewController:stepViewController didFinishWithNavigationDirection:direction];
    }
    
    [self removeKVOIfNeeded];
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
            [self removeKVOIfNeeded];
            [vc.delegate stepViewController:vc didFinishWithNavigationDirection: RKSTStepViewControllerNavigationDirectionForward];
        }
    }
}

- (void) removeKVOIfNeeded
{
    if (self.observedVC) {
        @try {
            [self.observedVC removeObserver:self forKeyPath:kFinishedProperty];
            self.observedVC = nil;
        }
        @catch (NSException * __unused exception) {}
    }

}

/*********************************************************************************/
#pragma mark - TaskViewController Delegate
/*********************************************************************************/

- (void)taskViewController:(RKSTTaskViewController *)taskViewController stepViewControllerWillAppear:(RKSTStepViewController *)stepViewController
{
    if ([self advanceArrayContainsStep:stepViewController.step])
    {
        self.observedVC = stepViewController;
        [stepViewController addObserver:self forKeyPath:kFinishedProperty options:NSKeyValueObservingOptionNew context:NULL];
    }
}

- (void)taskViewControllerDidCancel:(RKSTTaskViewController *)taskViewController
{
    [self removeKVOIfNeeded];
    [super taskViewControllerDidCancel:taskViewController];
}

- (void)taskViewControllerDidComplete:(RKSTTaskViewController *)taskViewController
{
    [self removeKVOIfNeeded];
    [super taskViewControllerDidComplete:taskViewController];
}

@end
