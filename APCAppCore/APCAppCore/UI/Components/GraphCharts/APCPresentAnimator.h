// 
//  APCPresentAnimator.h 
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//
 
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface APCPresentAnimator : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic) CGRect initialFrame;
@property (nonatomic, getter=isPresenting) BOOL presenting;

@end
