//
//  APCSignupTouchIDViewController.h
//  APCAppCore
//
//  Created by Karthik Keyan on 9/3/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APCSignUpProgressing.h"
#import "APCUserInfoConstants.h"

@interface APCSignupPasscodeViewController : UIViewController <APCSignUpProgressing>

- (void)next;

@end
