// 
//  APCUserInfoViewController.h 
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//
 
#import <UIKit/UIKit.h>
#import "APCTextFieldTableViewCell.h"
#import "APCPickerTableViewCell.h"
#import "APCSegmentedTableViewCell.h"
#import "APCDefaultTableViewCell.h"
#import "APCSwitchTableViewCell.h"
#import "APCUser+UserData.h"
#import "APCTableViewItem.h"

@interface APCUserInfoViewController : UITableViewController <APCTextFieldTableViewCellDelegate, APCSegmentedTableViewCellDelegate, APCPickerTableViewCellDelegate, APCSwitchTableViewCellDelegate, UITextFieldDelegate>

/*
 Items is an Array of APCTableViewSection
 */
@property (nonatomic, strong) NSArray *items;

@property (nonatomic, getter=isPickerShowing) BOOL pickerShowing;

@property (nonatomic, strong) NSIndexPath *pickerIndexPath;

@property (nonatomic, getter=isEditing, setter=setEditing:) BOOL editing;

@property (nonatomic, getter=isSignup) BOOL signUp;

- (void)setupDefaultCellAppearance:(APCDefaultTableViewCell *)cell;

- (void)setupPickerCellAppeareance:(APCPickerTableViewCell *)cell;

- (void)setupTextFieldCellAppearance:(APCTextFieldTableViewCell *)cell;

- (void)setupSegmentedCellAppearance:(APCSegmentedTableViewCell *)cell;

- (void)setupSwitchCellAppearance:(APCSwitchTableViewCell *)cell;

- (void)setupBasicCellAppearance:(UITableViewCell *)cell;

- (void)nextResponderForIndexPath:(NSIndexPath *)indexPath;

- (void)showPickerAtIndex:(NSIndexPath *)indexPath;

- (void)hidePickerCell;

- (APCTableViewItem *)itemForIndexPath:(NSIndexPath *)indexPath;

- (APCTableViewItemType)itemTypeForIndexPath:(NSIndexPath *)indexPath;

@end
