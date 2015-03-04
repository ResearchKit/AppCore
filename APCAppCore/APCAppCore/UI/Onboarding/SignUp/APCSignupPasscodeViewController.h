// 
//  APCSignupPasscodeViewController.h 
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//
 
#import <UIKit/UIKit.h>
#import "APCSignUpProgressing.h"
#import "APCUserInfoConstants.h"

@interface APCSignupPasscodeViewController : UIViewController <APCSignUpProgressing>

- (void)next;

@end
