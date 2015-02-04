//
//  APCFadeAnimator.m
//  APCAppCore
//
//  Created by Ramsundar Shandilya on 2/3/15.
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCFadeAnimator.h"

@implementation APCFadeAnimator

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return 0.3;
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
            
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
    } else {
        
        
        fromViewController.view.alpha = 1;
        
        [UIView animateWithDuration:0.3 animations:^{
            
            fromViewController.view.alpha = 0;
            
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
    }
    
}

@end
