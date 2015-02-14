//
//  APCFadeAnimator.m
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCFadeAnimator.h"

@implementation APCFadeAnimator

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>) __unused transitionContext
{
    return 0.2;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController* toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController* fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    if (self.isPresenting) {
        
        [transitionContext.containerView addSubview:toViewController.view];
        
        toViewController.view.alpha = 0;
        
        [UIView animateWithDuration:0.3 animations:^{
            
            toViewController.view.alpha = 1;
            
        } completion:^(BOOL __unused finished) {
            [transitionContext completeTransition:YES];
        }];
    } else {
        
        
        fromViewController.view.alpha = 1;
        
        [UIView animateWithDuration:0.3 animations:^{
            
            fromViewController.view.alpha = 0;
            
        } completion:^(BOOL __unused finished) {
            [transitionContext completeTransition:YES];
        }];
    }
    
}

@end
