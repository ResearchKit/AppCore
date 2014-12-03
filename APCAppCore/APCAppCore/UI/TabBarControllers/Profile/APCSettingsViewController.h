//
//  APCSettingsViewController.h
//  APCAppCore
//
//  Created by Ramsundar Shandilya on 11/1/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APCUserInfoViewController.h"
#import "APCParameters+Settings.h"

typedef NS_ENUM(APCTableViewItemType, APCSettingsItemType) {
    kAPCSettingsItemTypeAutoLock,
    kAPCSettingsItemTypePasscode,
    kAPCSettingsItemTypePassword,
    kAPCSettingsItemTypePushNotifications,
    kAPCSettingsItemTypeDevices
};

@interface APCSettingsViewController : APCUserInfoViewController

@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@property (nonatomic, strong) APCParameters *parameters;

@end
