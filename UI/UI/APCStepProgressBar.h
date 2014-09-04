//
//  APCStepProgressBar.h
//  UI
//
//  Created by Karthik Keyan on 9/3/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface APCStepProgressBar : UIView

@property (nonatomic, readwrite) NSUInteger numberOfSteps;

@property (nonatomic, readonly) NSUInteger completedSteps;

@property (nonatomic, readonly) UILabel *leftLabel;

@property (nonatomic, readonly) UILabel *rightLabel;

@property (nonatomic, readonly) UIProgressView *progressView;

- (instancetype) init NS_UNAVAILABLE;

- (void) setCompletedSteps:(NSUInteger)completedStep animation:(BOOL)animation;

@end
