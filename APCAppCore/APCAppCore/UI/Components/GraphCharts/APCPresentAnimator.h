// 
//  APCPresentAnimator.h 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface APCPresentAnimator : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic) CGRect initialFrame;
@property (nonatomic, getter=isPresenting) BOOL presenting;

@end
