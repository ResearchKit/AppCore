//
//  APCPresentAnimator.m
//  APCAppleCore
//
//  Created by Ramsundar Shandilya on 11/2/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCPresentAnimator.h"

@implementation APCPresentAnimator

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return 0.3;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController* toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController* fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    [[transitionContext containerView] addSubview:toViewController.view];
    
    toViewController.view.alpha = 0.f;
    
    if (self.isPresenting) {
        
        toViewController.view.frame = CGRectMake(CGRectGetMidX(self.initialFrame), CGRectGetMidY(self.initialFrame), 0, 0);
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            toViewController.view.frame = fromViewController.view.frame;
            toViewController.view.alpha = 1.f;
            
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
        
    }else {
        
        toViewController.view.alpha = 0.1;
        
        fromViewController.view.frame = toViewController.view.frame;
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            
            fromViewController.view.frame = self.initialFrame;
            fromViewController.view.alpha = 0;
            toViewController.view.alpha = 1;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
            
        }];
    }
}

@end
