// 
//  APCSignUpProgressing.h 
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
//
 
@import Foundation;

@class APCUser, APCStepProgressBar;

@protocol APCSignUpProgressing <NSObject>

@property (nonatomic, strong) APCUser *user;

@property (nonatomic, strong) APCStepProgressBar *stepProgressBar;

@end
