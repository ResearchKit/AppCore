// 
//  APCSignUpPermissionsViewController.h 
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//
 
#import <UIKit/UIKit.h>
#import "APCSignUpProgressing.h"

@interface APCSignUpPermissionsViewController : UITableViewController <APCSignUpProgressing>

@property (nonatomic, strong) NSArray *permissions;

- (void)finishOnboarding;

@end
