//
//  APCSettingsViewController.h
//  APCAppleCore
//
//  Created by Ramsundar Shandilya on 11/1/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APCUserInfoViewController.h"
#import "APCParameters+Settings.h"

@interface APCSettingsViewController : APCUserInfoViewController

@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@property (nonatomic, strong) APCParameters *parameters;

@end
