//
//  APCStepProgressBar.m
//  UI
//
//  Created by Karthik Keyan on 9/3/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCStepProgressBar.h"

@implementation APCStepProgressBar

- (instancetype) initWithFrame:(CGRect)frame style:(APCStepProgressBarStyle)style {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.clipsToBounds = YES;
        
        _style = style;
        
        [self loadViews];
    }
    return self;
}

- (void) loadViews {
    CGFloat const MARGIN = 10;
    CGRect frame = self.bounds;
    
    if (self.style == APCStepProgressBarStyleDefault) {
        CGFloat availableWidth = self.bounds.size.width - (2 * MARGIN);
        
        {
            frame.size.width = availableWidth * 0.75;
            frame.origin.x = MARGIN;
            
            _leftLabel = [UILabel new];
            _leftLabel.frame = frame;
            _leftLabel.font = [UIFont boldSystemFontOfSize:14.0];
            [self addSubview:_leftLabel];
        }

        {
            frame.origin.x = CGRectGetMaxX(frame);
            frame.size.width = availableWidth * 0.25;
            
            _rightLabel = [UILabel new];
            _rightLabel.frame = frame;
            _rightLabel.font = [UIFont systemFontOfSize:12.0];
            _rightLabel.textAlignment = NSTextAlignmentRight;
            [self addSubview:_rightLabel];
        }
    }
    
    _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    _progressView.frame = CGRectMake(0, self.bounds.size.height - 1, self.bounds.size.width, 1);
    _progressView.trackTintColor = [UIColor colorWithRed:248/255.0 green:248/255.0 blue:248/255.0 alpha:1.0];
    _progressView.progressTintColor = [UIColor colorWithRed:45/255.0 green:180/255.0 blue:251/255.0 alpha:1.0];
    [self addSubview:_progressView];
    
    if (self.style == APCStepProgressBarStyleOnlyProgressView) {
        _progressView.frame = self.bounds;
    }
    else {
        _progressView.frame = CGRectMake(0, self.bounds.size.height - 1, self.bounds.size.width, 1);
    }
}

- (void) setCompletedSteps:(NSUInteger)completedStep animation:(BOOL)animation {
    _completedSteps = completedStep;
    
    CGFloat progress = (CGFloat)completedStep/self.numberOfSteps;
    
    [self.progressView setProgress:progress animated:animation];
}

@end
