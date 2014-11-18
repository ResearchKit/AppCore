//
//  APCPresentAnimator.h
//  APCAppleCore
//
//  Created by Ramsundar Shandilya on 11/2/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface APCPresentAnimator : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic) CGRect initialFrame;
@property (nonatomic) BOOL isPresenting;

@end
