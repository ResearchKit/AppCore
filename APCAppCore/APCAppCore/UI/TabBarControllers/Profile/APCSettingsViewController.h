// 
//  APCSettingsViewController.h 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import <UIKit/UIKit.h>
#import "APCUserInfoViewController.h"
#import "APCParameters+Settings.h"

@interface APCSettingsViewController : APCUserInfoViewController

@property (nonatomic, strong) APCParameters *parameters;

@end
