// 
//  APCPresentAnimator.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "APCPresentAnimator.h"

@implementation APCPresentAnimator

- (NSTimeInterval) transitionDuration: (id <UIViewControllerContextTransitioning>) __unused transitionContext
{
    return 0.3;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController* toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController* fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    if (self.isPresenting) {
        
        [transitionContext.containerView addSubview:fromViewController.view];
        [transitionContext.containerView addSubview:toViewController.view];
        
        toViewController.view.frame = self.initialFrame;
        
        CGRect finalFrame = CGRectMake(0, 0, CGRectGetWidth(fromViewController.view.frame), CGRectGetHeight(fromViewController.view.frame));
        
        [UIView animateWithDuration:0.3 animations:^{
            fromViewController.view.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
            
            toViewController.view.transform = CGAffineTransformMakeRotation(-M_PI_2);
            toViewController.view.frame = finalFrame;
            
            
        } completion:^(BOOL __unused finished) {
            [transitionContext completeTransition:YES];
        }];
        
    }else {
        
        [transitionContext.containerView addSubview:toViewController.view];
        [transitionContext.containerView addSubview:fromViewController.view];
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            toViewController.view.tintAdjustmentMode = UIViewTintAdjustmentModeAutomatic;
            
            fromViewController.view.transform = CGAffineTransformMakeRotation(0);
            fromViewController.view.frame = self.initialFrame;
            fromViewController.view.alpha = 0;
        } completion:^(BOOL __unused finished) {
            [transitionContext completeTransition:YES];
        }];
    }
}

@end
