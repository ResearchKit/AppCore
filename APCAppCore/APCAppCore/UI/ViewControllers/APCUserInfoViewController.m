// 
//  APCUserInfoViewController.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "APCUserInfoViewController.h"
#import "NSDate+Helper.h"
#import "UIColor+APCAppearance.h"
#import "UIFont+APCAppearance.h"
#import "APCAppCore.h"

static CGFloat const kPickerCellHeight = 164.0f;

@interface APCUserInfoViewController ()

@end

@implementation APCUserInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
  APCLogViewControllerAppeared();
}

#pragma mark - Custom Methods

- (void)setupPickerCellAppeareance:(APCPickerTableViewCell *)cell{}

- (void)setupTextFieldCellAppearance:(APCTextFieldTableViewCell *)cell{}

- (void)setupSegmentedCellAppearance:(APCSegmentedTableViewCell *)cell{}

- (void)setupDefaultCellAppearance:(APCDefaultTableViewCell *)cell{}

- (void)setupSwitchCellAppearance:(APCSwitchTableViewCell *)cell{}

- (void)setupBasicCellAppearance:(UITableViewCell *)cell
{
    [cell.textLabel setTextColor:[UIColor appSecondaryColor1]];
    [cell.textLabel setFont:[UIFont appRegularFontWithSize:14.0f]];
}

#pragma mark - UITableViewDataSource methods

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    return self.items.count;
//}
//
//- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    APCTableViewSection *itemsSection = self.items[section];
//    
//    NSInteger count = itemsSection.rows.count;
//    
//    if (self.isPickerShowing && self.pickerIndexPath.section == section) {
//        count ++;
//    }
//    
//    return count;
//}
//
//- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    UITableViewCell *cell;
//    
//    if (self.pickerIndexPath && [self.pickerIndexPath isEqual:indexPath]) {
//        cell = [tableView dequeueReusableCellWithIdentifier:kAPCPickerTableViewCellIdentifier];
//        
//        NSIndexPath *actualIndexPath = [NSIndexPath indexPathForRow:(indexPath.row - 1) inSection:indexPath.section];
//        APCTableViewItem *field = [self itemForIndexPath:actualIndexPath];
//        
//        APCPickerTableViewCell *pickerCell = (APCPickerTableViewCell *)cell;
//        
//        if ([field isKindOfClass:[APCTableViewDatePickerItem class]]) {
//            
//            APCTableViewDatePickerItem *datePickerField = (APCTableViewDatePickerItem *)field;
//            
//            pickerCell.type = kAPCPickerCellTypeDate;
//            if (datePickerField.date) {
//                pickerCell.datePicker.date = datePickerField.date;
//            }
//            
//            pickerCell.datePicker.datePickerMode = datePickerField.datePickerMode;
//            if (datePickerField.minimumDate) {
//                pickerCell.datePicker.minimumDate = datePickerField.minimumDate;
//            }
//            if (datePickerField.maximumDate) {
//                pickerCell.datePicker.maximumDate = datePickerField.maximumDate;
//            }
//            pickerCell.delegate = self;
//            
//            [self setupPickerCellAppeareance:pickerCell];
//            
//        } else if ([field isKindOfClass:[APCTableViewCustomPickerItem class]]){
//            
//            APCTableViewCustomPickerItem *customPickerField = (APCTableViewCustomPickerItem *)field;
//            pickerCell.type = kAPCPickerCellTypeCustom;
//            pickerCell.pickerValues = customPickerField.pickerData;
//            [pickerCell.pickerView reloadAllComponents];
//            pickerCell.delegate = self;
//            pickerCell.selectedRowIndices = customPickerField.selectedRowIndices;
//            
//            [self setupPickerCellAppeareance:pickerCell];
//        }
//        
//    } else {
//        
//        APCTableViewItem *field = [self itemForIndexPath:indexPath];
//        
//        if (field) {
//            
//            cell = [tableView dequeueReusableCellWithIdentifier:field.identifier];
//            
//            cell.selectionStyle = field.selectionStyle;
//            cell.textLabel.text = field.caption;
//            cell.detailTextLabel.text = field.detailText;
//            
//            if ([field isKindOfClass:[APCTableViewTextFieldItem class]]) {
//                
//                APCTableViewTextFieldItem *textFieldItem = (APCTableViewTextFieldItem *)field;
//                APCTextFieldTableViewCell *textFieldCell = (APCTextFieldTableViewCell *)cell;
//                
//                textFieldCell.textField.placeholder = textFieldItem.placeholder;
//                textFieldCell.textField.text = textFieldItem.value;
//                textFieldCell.textField.secureTextEntry = textFieldItem.isSecure;
//                textFieldCell.textField.keyboardType = textFieldItem.keyboardType;
//                textFieldCell.textField.returnKeyType = textFieldItem.returnKeyType;
//                textFieldCell.textField.clearButtonMode = textFieldItem.clearButtonMode;
//                textFieldCell.textField.text = textFieldItem.value;
//                textFieldCell.textField.enabled = self.isEditing;
//                
//                if (field.textAlignnment == NSTextAlignmentRight) {
//                    textFieldCell.type = kAPCTextFieldCellTypeRight;
//                } else {
//                    textFieldCell.type = kAPCTextFieldCellTypeLeft;
//                }
//                
//                textFieldCell.delegate = self;
//                
//                [self setupTextFieldCellAppearance:textFieldCell];
//                
//                cell = textFieldCell;
//            }
//            else if ([field isKindOfClass:[APCTableViewDatePickerItem class]]) {
//                
//                APCTableViewDatePickerItem *datePickerField = (APCTableViewDatePickerItem *)field;
//                APCDefaultTableViewCell *defaultCell = (APCDefaultTableViewCell *)cell;
//                
//                if (datePickerField.date) {
//                    NSString *dateWithFormat = [datePickerField.date toStringWithFormat:datePickerField.dateFormat];
//                    defaultCell.detailTextLabel.text = dateWithFormat;
//                    defaultCell.detailTextLabel.textColor = [UIColor appSecondaryColor1];
//                } else {
//                    defaultCell.detailTextLabel.text = field.placeholder;
//                    defaultCell.detailTextLabel.textColor = [UIColor appSecondaryColor3];
//                }
//                
//                
//                if (field.textAlignnment == NSTextAlignmentRight) {
//                    defaultCell.type = kAPCDefaultTableViewCellTypeRight;
//                } else {
//                    defaultCell.type = kAPCDefaultTableViewCellTypeLeft;
//                }
//                
//                [self setupDefaultCellAppearance:defaultCell];
//                
//            }
//            else if ([field isKindOfClass:[APCTableViewCustomPickerItem class]]) {
//                
//                APCTableViewCustomPickerItem *customPickerField = (APCTableViewCustomPickerItem *)field;
//                APCDefaultTableViewCell *defaultCell = (APCDefaultTableViewCell *)cell;
//                
//                defaultCell.detailTextLabel.text = customPickerField.stringValue;
//                
//                if (field.textAlignnment == NSTextAlignmentRight) {
//                    defaultCell.type = kAPCDefaultTableViewCellTypeRight;
//                } else {
//                    defaultCell.type = kAPCDefaultTableViewCellTypeLeft;
//                }
//                
//                [self setupDefaultCellAppearance:defaultCell];
//                
//            } else if ([field isKindOfClass:[APCTableViewSegmentItem class]]) {
//                
//                APCTableViewSegmentItem *segmentPickerField = (APCTableViewSegmentItem *)field;
//                APCSegmentedTableViewCell *segmentedCell = (APCSegmentedTableViewCell *)cell;
//                segmentedCell.delegate = self;
//                segmentedCell.selectedSegmentIndex = segmentPickerField.selectedIndex;
//                segmentedCell.userInteractionEnabled = segmentPickerField.editable;
//                
//            } else if ([field isKindOfClass:[APCTableViewSwitchItem class]]) {
//                
//                APCTableViewSwitchItem *switchField = (APCTableViewSwitchItem *)field;
//                APCSwitchTableViewCell *switchCell = (APCSwitchTableViewCell *)cell;
//                switchCell.textLabel.text = switchField.caption;
//                switchCell.cellSwitch.on = switchField.on;
//                switchCell.delegate = self;
//                
//                [self setupSwitchCellAppearance:switchCell];
//            } else {
//                if (!cell) {
//                    cell = [[UITableViewCell alloc] initWithStyle:field.style reuseIdentifier:field.identifier];
//                }
//                [self setupBasicCellAppearance:cell];
//            }
//            
//            if (self.isEditing && field.editable && !self.signUp) {
//                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//                cell.selectionStyle = UITableViewCellSelectionStyleGray;
//            } else{
//                cell.accessoryType = UITableViewCellAccessoryNone;
//                cell.selectionStyle = UITableViewCellSelectionStyleNone;
//            }
//        }
//        
//    }
//    
//    return cell;
//}
//
#pragma mark - UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = tableView.rowHeight;
    
    if (self.isPickerShowing && [indexPath isEqual:self.pickerIndexPath]) {
        height = kPickerCellHeight;
    }
    
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    APCTableViewItem *field = [self itemForIndexPath:indexPath];
    
    if (self.isEditing && field.isEditable && ([field isKindOfClass:[APCTableViewCustomPickerItem class]] ||
                             [field isKindOfClass:[APCTableViewDatePickerItem class]])) {
        
        [self.tableView endEditing:YES];
        [self handlePickerForIndexPath:indexPath];
        
    } else if ([field isKindOfClass:[APCTableViewTextFieldItem class]]){
        
        NSIndexPath *actualIndexPath = indexPath;
        
        if (self.pickerShowing) {
            if ((indexPath.row > self.pickerIndexPath.row) && (indexPath.section == self.pickerIndexPath.section)) {
                actualIndexPath = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section];
            }
            
            [self hidePickerCell];
        }
        
        if (self.isEditing) {
            APCTextFieldTableViewCell *cell = (APCTextFieldTableViewCell *)[tableView cellForRowAtIndexPath:actualIndexPath];
            [cell.textField becomeFirstResponder];
        }
    } else{
        if (self.pickerShowing) {
            [self hidePickerCell];
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - APCPickerTableViewCellDelegate methods

- (void)pickerTableViewCell:(APCPickerTableViewCell *)cell datePickerValueChanged:(NSDate *)date
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    if (self.pickerShowing && indexPath) {
        
        APCTableViewDatePickerItem *field = (APCTableViewDatePickerItem *)[self itemForIndexPath:indexPath];
        field.date = date;
        
        NSString *dateWithFormat = [field.date toStringWithFormat:field.dateFormat];
        field.detailText = dateWithFormat;
        
        UITableViewCell *dateCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section]];
        dateCell.detailTextLabel.text = dateWithFormat;
    }
}

- (void)pickerTableViewCell:(APCPickerTableViewCell *)cell pickerViewDidSelectIndices:(NSArray *)selectedIndices
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    if (self.pickerShowing && indexPath) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        
        APCTableViewCustomPickerItem *field = (APCTableViewCustomPickerItem *)[self itemForIndexPath:indexPath];
        field.selectedRowIndices = selectedIndices;
        
        UITableViewCell *dateCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section]];
        dateCell.detailTextLabel.text = field.stringValue;
    }
}

#pragma mark - APCTextFieldTableViewCellDelegate methods

- (void)textFieldTableViewCellDidBeginEditing:(APCTextFieldTableViewCell *)cell
{
    if (self.pickerShowing) {
        [self hidePickerCell];
    }
}

- (void)textFieldTableViewCellDidChangeText:(APCTextFieldTableViewCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    NSString *text = cell.textField.text;
    
    APCTableViewTextFieldItem *textFieldItem = (APCTableViewTextFieldItem *)[self itemForIndexPath:indexPath];
    textFieldItem.value = text;
}

- (void)textFieldTableViewCellDidEndEditing:(APCTextFieldTableViewCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    APCTableViewTextFieldItem *textFieldItem = (APCTableViewTextFieldItem *)[self itemForIndexPath:indexPath];
    textFieldItem.value = cell.textField.text;
}

- (void)textFieldTableViewCellDidReturn:(APCTextFieldTableViewCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    [self nextResponderForIndexPath:indexPath];
}

- (void)nextResponderForIndexPath:(NSIndexPath *)indexPath
{
    NSInteger lastRowIndex = [self.tableView numberOfRowsInSection:indexPath.section] - 1;
    
    NSInteger currentRowIndex = -1;
    if (indexPath) {
        currentRowIndex = indexPath.row;
    }
    
    if (currentRowIndex < lastRowIndex) {
        
        NSInteger nextRowIndex = -1;
        
        for (NSInteger i = currentRowIndex + 1; i <= lastRowIndex; i++) {
            NSIndexPath *nextIndexPath = [NSIndexPath indexPathForRow:i inSection:indexPath.section];
            APCTableViewItem *field = [self itemForIndexPath:nextIndexPath];
            if ([field isKindOfClass:[APCTableViewTextFieldItem class]]) {
                nextRowIndex = i;
                break;
            }
        }
        
        if (nextRowIndex >= 0) {
            APCTextFieldTableViewCell *nextCell = (APCTextFieldTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:nextRowIndex inSection:0]];
            [nextCell.textField becomeFirstResponder];
        } else{
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            [cell resignFirstResponder];
        }
    }
}

#pragma mark - APCSegmentedTableViewCellDelegate methods

- (void)segmentedTableViewCell:(APCSegmentedTableViewCell *)cell didSelectSegmentAtIndex:(NSInteger)index
{
    if (self.pickerShowing) {
        [self hidePickerCell];
    }
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    APCTableViewSegmentItem *field = (APCTableViewSegmentItem *)[self itemForIndexPath:indexPath];
    field.selectedIndex = index;
}

#pragma mark - APCSwitchTableViewCellDelegate methods

- (void)switchTableViewCell:(APCSwitchTableViewCell *)cell switchValueChanged:(BOOL)on
{
    if (self.pickerShowing) {
        [self hidePickerCell];
    }
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    APCTableViewSwitchItem *field = (APCTableViewSwitchItem *)[self itemForIndexPath:indexPath];
    field.on = on;
}

#pragma mark - Private Methods

- (void)handlePickerForIndexPath:(NSIndexPath *)indexPath
{
    if (self.isPickerShowing && (self.pickerIndexPath.row - 1 == indexPath.row) && (indexPath.section == self.pickerIndexPath.section)) {
        [self hidePickerCell];
    } else{
        NSIndexPath *selectedIndexpath = [self actualSelectedIndexPath:indexPath];
        
        if (self.isPickerShowing) {
            [self hidePickerCell];
        }
        
        [self showPickerAtIndex:selectedIndexpath];
    }
}

- (void)showPickerAtIndex:(NSIndexPath *)indexPath
{
    self.pickerShowing = YES;
    
    self.pickerIndexPath = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section];
    
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:@[self.pickerIndexPath]
                          withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
    
    [self.tableView scrollToRowAtIndexPath:self.pickerIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (void)hidePickerCell
{
    self.pickerShowing = NO;
    
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.pickerIndexPath.row inSection:self.pickerIndexPath.section]]
                          withRowAnimation:UITableViewRowAnimationFade];
    
    
    self.pickerIndexPath = nil;
    [self.tableView endUpdates];
}

- (NSIndexPath *)actualSelectedIndexPath:(NSIndexPath *)selectedIndexPath {
    
    NSIndexPath *newIndexPath;
    
    if (self.isPickerShowing && (self.pickerIndexPath.row <= selectedIndexPath.row) && (self.pickerIndexPath.section == selectedIndexPath.section)){
        newIndexPath = [NSIndexPath indexPathForRow:selectedIndexPath.row - 1 inSection:selectedIndexPath.section];
    }else {
        newIndexPath = [NSIndexPath indexPathForRow:selectedIndexPath.row  inSection:selectedIndexPath.section];
    }
    
    return newIndexPath;
}

- (APCTableViewItem *)itemForIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *actualIndexPath = [self actualSelectedIndexPath:indexPath];
    
    APCTableViewSection *itemSection = self.items[actualIndexPath.section];
    APCTableViewRow *itemRow = itemSection.rows[actualIndexPath.row];
    
    return itemRow.item;
}

- (APCTableViewItemType)itemTypeForIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *actualIndexPath = [self actualSelectedIndexPath:indexPath];
    
    APCTableViewSection *itemSection = self.items[actualIndexPath.section];
    APCTableViewRow *itemRow = itemSection.rows[actualIndexPath.row];
    
    return itemRow.itemType;
}

@end
