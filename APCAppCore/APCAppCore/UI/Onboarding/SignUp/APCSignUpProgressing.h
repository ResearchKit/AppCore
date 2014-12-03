//
//  APCSignUpProgressing.h
//  APCAppCore
//
//  Created by Karthik Keyan on 9/3/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

@import Foundation;

@class APCUser, APCStepProgressBar;

@protocol APCSignUpProgressing <NSObject>

@property (nonatomic, strong) APCUser *user;

@property (nonatomic, strong) APCStepProgressBar *stepProgressBar;

@end
