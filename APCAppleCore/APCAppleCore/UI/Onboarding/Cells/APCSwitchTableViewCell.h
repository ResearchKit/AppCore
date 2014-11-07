//
//  APCSwitchTableViewCell.h
//  APCAppleCore
//
//  Created by Ramsundar Shandilya on 11/1/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *const kAPCSwitchCellIdentifier = @"APCSwitchTableViewCell";

@protocol APCSwitchTableViewCellDelegate;

@interface APCSwitchTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *textLabel;

@property (nonatomic, weak) IBOutlet UISwitch *cellSwitch;

@property (nonatomic, weak) id <APCSwitchTableViewCellDelegate> delegate;

@end

@protocol APCSwitchTableViewCellDelegate <NSObject>

- (void)switchTableViewCell:(APCSwitchTableViewCell *)cell switchValueChanged:(BOOL)on;

@end
