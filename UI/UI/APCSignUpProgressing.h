//
//  APCSignUpProgressing.h
//  UI
//
//  Created by Karthik Keyan on 9/3/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

@import Foundation;

static CGFloat const kAPCSignUpProgressBarHeight = 14;

@class APCStepProgressBar;

@protocol APCSignUpProgressing <NSObject>

@property (nonatomic, strong) APCStepProgressBar *stepProgressBar;

- (void) setStepNumber:(NSUInteger)stepNumber title:(NSString *)title;

@end
