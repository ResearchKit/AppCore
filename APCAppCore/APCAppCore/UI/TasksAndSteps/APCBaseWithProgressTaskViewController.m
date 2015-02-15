// 
//  APCBaseWithProgressTaskViewController.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "APCBaseWithProgressTaskViewController.h"
#import "APCAppCore.h"

static NSString *const kFinishedProperty = @"finished";

@interface APCBaseWithProgressTaskViewController ()
@property  (nonatomic, weak)  APCStepProgressBar  *progressor;
@property  (nonatomic, weak)  ORKStepViewController * observedVC;
@end

@implementation APCBaseWithProgressTaskViewController

/*********************************************************************************/
#pragma mark - StepViewController Delegate Methods
/*********************************************************************************/

- (void)stepViewController:(ORKStepViewController *)stepViewController didFinishWithNavigationDirection:(ORKStepViewControllerNavigationDirection)direction
{
    if ([super respondsToSelector:@selector(stepViewController:didFinishWithNavigationDirection:)]) {
        [super stepViewController:stepViewController didFinishWithNavigationDirection:direction];
    }
    
    [self removeKVOIfNeeded];
}


- (BOOL) advanceArrayContainsStep: (ORKStep*) step
{
    __block BOOL retValue = NO;
    [self.stepsToAutomaticallyAdvanceOnTimer enumerateObjectsUsingBlock:^(NSString* stepID, NSUInteger __unused idx, BOOL * __unused stop) {
        if([step.identifier isEqualToString:stepID])
        {
            retValue = YES;
        }
    }];
    return retValue;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *) __unused change
                       context:(void *) __unused context
{
    if ([keyPath isEqualToString:kFinishedProperty]) {
        if ([object isFinished]) {
            ORKStepViewController * vc = object;
            [self removeKVOIfNeeded];
            [vc.delegate stepViewController:vc didFinishWithNavigationDirection: ORKStepViewControllerNavigationDirectionForward];
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

- (void)taskViewController:(ORKTaskViewController *) __unused taskViewController stepViewControllerWillAppear:(ORKStepViewController *)stepViewController
{
    if ([self advanceArrayContainsStep:stepViewController.step])
    {
        self.observedVC = stepViewController;
        [stepViewController addObserver:self forKeyPath:kFinishedProperty options:NSKeyValueObservingOptionNew context:NULL];
    }
}

- (void)taskViewControllerDidCancel:(ORKTaskViewController *)taskViewController
{
    [self removeKVOIfNeeded];
    [super taskViewControllerDidCancel:taskViewController];
}

- (void)taskViewControllerDidComplete:(ORKTaskViewController *)taskViewController
{
    [self removeKVOIfNeeded];
    [super taskViewControllerDidComplete:taskViewController];
}

@end
