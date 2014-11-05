//
//  APCSettingsViewController.h
//  APCAppleCore
//
//  Created by Ramsundar Shandilya on 11/1/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APCSwitchTableViewCell.h"

@interface APCSettingsViewController : UITableViewController <APCSwitchTableViewCellDelegate>

@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@end
