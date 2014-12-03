// 
//  APCSignupPasscodeViewController.h 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import <UIKit/UIKit.h>
#import "APCSignUpProgressing.h"
#import "APCUserInfoConstants.h"

@interface APCSignupPasscodeViewController : UIViewController <APCSignUpProgressing>

- (void)next;

@end
