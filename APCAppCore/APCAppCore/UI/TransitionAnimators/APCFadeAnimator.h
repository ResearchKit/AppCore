//
//  APCFadeAnimator.h
//  APCAppCore
//
//  Created by Ramsundar Shandilya on 2/3/15.
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface APCFadeAnimator : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, getter=isPresenting) BOOL presenting;

@end
