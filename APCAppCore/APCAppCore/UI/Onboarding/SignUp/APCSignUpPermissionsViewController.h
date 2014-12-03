// 
//  APCSignUpPermissionsViewController.h 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import <UIKit/UIKit.h>
#import "APCSignUpProgressing.h"

@interface APCSignUpPermissionsViewController : UITableViewController <APCSignUpProgressing>

@property (nonatomic, strong) NSArray *permissions;

- (void)finishSignUp;

@end
