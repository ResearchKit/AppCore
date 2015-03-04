// 
//  APCSettingsViewController.h 
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
//
 
#import <UIKit/UIKit.h>
#import "APCUserInfoViewController.h"
#import "APCParameters+Settings.h"

@interface APCSettingsViewController : APCUserInfoViewController

@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@property (nonatomic, strong) APCParameters *parameters;

@end
