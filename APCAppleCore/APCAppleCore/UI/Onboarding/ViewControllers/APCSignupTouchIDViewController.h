//
//  APCSignupTouchIDViewController.h
//  APCAppleCore
//
//  Created by Karthik Keyan on 9/3/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCSignupViewController.h"
#import "APCUserInfoConstants.h"

@interface APCSignupTouchIDViewController : UIViewController <APCSignUpProgressing>

- (IBAction)skip;
- (void)next;

@end
