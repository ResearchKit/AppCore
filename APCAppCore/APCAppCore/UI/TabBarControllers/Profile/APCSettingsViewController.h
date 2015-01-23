// 
//  APCSettingsViewController.h 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import <UIKit/UIKit.h>
#import "APCUserInfoViewController.h"
#import "APCParameters+Settings.h"

typedef NS_ENUM(APCTableViewItemType, APCSettingsItemType) {
    kAPCSettingsItemTypeAutoLock,
    kAPCSettingsItemTypePasscode,
    kAPCSettingsItemTypeReminderOnOff,
    kAPCSettingsItemTypeReminderTime,
    kAPCSettingsItemTypePermissions
};

@interface APCSettingsViewController : APCUserInfoViewController

@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@property (nonatomic, strong) APCParameters *parameters;

@end
