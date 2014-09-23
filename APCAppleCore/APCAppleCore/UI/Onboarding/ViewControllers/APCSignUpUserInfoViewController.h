//
//  APCSignUpUserInfoViewController.h
//  APCAppleCore
//
//  Created by Karthik Keyan on 9/3/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCSignUpProgressing.h"
#import "APCUserInfoViewController.h"

@interface APCSignUpUserInfoViewController : APCUserInfoViewController <APCSignUpProgressing>

@property (nonatomic, strong) NSArray *itemsOrder;

@end
