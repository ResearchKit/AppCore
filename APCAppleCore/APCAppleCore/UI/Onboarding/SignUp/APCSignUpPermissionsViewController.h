//
//  APCSignUpPermissionsViewController.h
//  APCAppleCore
//
//  Created by Ramsundar Shandilya on 9/19/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APCSignUpProgressing.h"

@interface APCSignUpPermissionsViewController : UITableViewController <APCSignUpProgressing>

@property (nonatomic, strong) NSArray *permissions;

- (void)finishSignUp;

@end
