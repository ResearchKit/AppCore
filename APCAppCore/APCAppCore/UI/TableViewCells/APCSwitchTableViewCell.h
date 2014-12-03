// 
//  APCSwitchTableViewCell.h 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import <UIKit/UIKit.h>

FOUNDATION_EXPORT NSString *const kAPCSwitchCellIdentifier;

@protocol APCSwitchTableViewCellDelegate;

@interface APCSwitchTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *textLabel;

@property (nonatomic, weak) IBOutlet UISwitch *cellSwitch;

@property (nonatomic, weak) id <APCSwitchTableViewCellDelegate> delegate;

@end

@protocol APCSwitchTableViewCellDelegate <NSObject>

- (void)switchTableViewCell:(APCSwitchTableViewCell *)cell switchValueChanged:(BOOL)on;

@end
