//
//  APCUserInfoViewController.h
//  APCAppleCore
//
//  Created by Ramsundar Shandilya on 11/4/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APCTextFieldTableViewCell.h"
#import "APCPickerTableViewCell.h"
#import "APCSegmentedTableViewCell.h"
#import "APCDefaultTableViewCell.h"
#import "APCUser+HealthKit.h"
#import "APCTableViewItem.h"

@interface APCUserInfoViewController : UITableViewController <APCTextFieldTableViewCellDelegate, APCSegmentedTableViewCellDelegate, APCPickerTableViewCellDelegate, UITextFieldDelegate>

@property (nonatomic, strong) NSMutableArray *items;

@property (nonatomic, strong) NSMutableArray *itemsOrder;

@property (nonatomic, getter=isPickerShowing) BOOL pickerShowing;

@property (nonatomic, strong) NSIndexPath *pickerIndexPath;

@property (nonatomic, getter=isEditing) BOOL editing;

@property (nonatomic, getter=isSignup) BOOL signUp;

- (void)setupDefaultCellAppearance:(APCDefaultTableViewCell *)cell;

- (void)setupPickerCellAppeareance:(APCPickerTableViewCell *)cell;

- (void)setupTextFieldCellAppearance:(APCTextFieldTableViewCell *)cell;

- (void)setupSegmentedCellAppearance:(APCSegmentedTableViewCell *)cell;

- (void)nextResponderForIndexPath:(NSIndexPath *)indexPath;

- (void)showPickerAtIndex:(NSIndexPath *)indexPath;

- (void)hidePickerCell;

@end
