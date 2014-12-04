// 
//  APCSignUpProgressing.h 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
@import Foundation;

@class APCUser, APCStepProgressBar;

@protocol APCSignUpProgressing <NSObject>

@property (nonatomic, strong) APCUser *user;

@property (nonatomic, strong) APCStepProgressBar *stepProgressBar;

@end
