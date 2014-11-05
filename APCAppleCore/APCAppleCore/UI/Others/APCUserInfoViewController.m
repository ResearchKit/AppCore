//
//  APCUserInfoViewController.m
//  APCAppleCore
//
//  Created by Ramsundar Shandilya on 11/4/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCUserInfoViewController.h"
#import "APCAppDelegate.h"
#import "APCUserInfoConstants.h"
#import "NSDate+Helper.h"
#import "UIColor+APCAppearance.h"
#import "UIFont+APCAppearance.h"

@interface APCUserInfoViewController ()

@end

@implementation APCUserInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Custom Methods

- (void)setupPickerCellAppeareance:(APCPickerTableViewCell *)cell
{
    
}

- (void)setupTextFieldCellAppearance:(APCTextFieldTableViewCell *)cell
{
}

- (void)setupSegmentedCellAppearance:(APCSegmentedTableViewCell *)cell
{
    
}

- (void)setupDefaultCellAppearance:(APCDefaultTableViewCell *)cell
{
    
}

#pragma mark - UITableViewDataSource methods

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = self.items.count;
    
    if (self.isPickerShowing) {
        count ++;
    }
    
    return count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if (self.pickerIndexPath && self.pickerIndexPath.row == indexPath.row) {
        cell = [tableView dequeueReusableCellWithIdentifier:kAPCPickerTableViewCellIdentifier];
        
        APCTableViewItem *field = self.items[indexPath.row - 1];
        
        APCPickerTableViewCell *pickerCell = (APCPickerTableViewCell *)cell;
        
        if ([field isKindOfClass:[APCTableViewDatePickerItem class]]) {
            
            APCTableViewDatePickerItem *datePickerField = (APCTableViewDatePickerItem *)field;
            
            pickerCell.type = kAPCPickerCellTypeDate;
            if (datePickerField.date) {
                pickerCell.datePicker.date = datePickerField.date;
            }
            
            pickerCell.datePicker.datePickerMode = datePickerField.datePickerMode;
            if (datePickerField.minimumDate) {
                pickerCell.datePicker.minimumDate = datePickerField.minimumDate;
            }
            if (datePickerField.maximumDate) {
                pickerCell.datePicker.maximumDate = datePickerField.maximumDate;
            }
            pickerCell.delegate = self;
            
            [self setupPickerCellAppeareance:pickerCell];
            
        } else if ([field isKindOfClass:[APCTableViewCustomPickerItem class]]){
            
            APCTableViewCustomPickerItem *customPickerField = (APCTableViewCustomPickerItem *)field;
            pickerCell.type = kAPCPickerCellTypeCustom;
            pickerCell.pickerValues = customPickerField.pickerData;
            [pickerCell.pickerView reloadAllComponents];
            pickerCell.delegate = self;
            
            [self setupPickerCellAppeareance:pickerCell];
        }
        
    } else {
        APCTableViewItem *field;
        
        if (self.isPickerShowing && (indexPath.row > self.pickerIndexPath.row)) {
            field = self.items[indexPath.row - 1];
        } else{
            field = self.items[indexPath.row];
        }
        
        if (field) {
            
            cell = [tableView dequeueReusableCellWithIdentifier:field.identifier];
            
            cell.selectionStyle = field.selectionStyle;
            cell.textLabel.text = field.caption;
            cell.detailTextLabel.text = field.detailText;
            
            if ([field isKindOfClass:[APCTableViewTextFieldItem class]]) {
                
                APCTableViewTextFieldItem *textFieldItem = (APCTableViewTextFieldItem *)field;
                APCTextFieldTableViewCell *textFieldCell = (APCTextFieldTableViewCell *)cell;
                
                textFieldCell.textField.placeholder = textFieldItem.placeholder;
                textFieldCell.textField.text = textFieldItem.value;
                textFieldCell.textField.secureTextEntry = textFieldItem.isSecure;
                textFieldCell.textField.keyboardType = textFieldItem.keyboardType;
                textFieldCell.textField.returnKeyType = textFieldItem.returnKeyType;
                textFieldCell.textField.clearButtonMode = textFieldItem.clearButtonMode;
                textFieldCell.textField.text = textFieldItem.value;
                textFieldCell.textField.enabled = self.isEditing;
                
                if (field.textAlignnment == NSTextAlignmentRight) {
                    textFieldCell.type = kAPCTextFieldCellTypeRight;
                } else {
                    textFieldCell.type = kAPCTextFieldCellTypeLeft;
                }
                
                textFieldCell.delegate = self;
                
                [self setupTextFieldCellAppearance:textFieldCell];
                
                cell = textFieldCell;
            }
            else if ([field isKindOfClass:[APCTableViewDatePickerItem class]]) {
                
                APCTableViewDatePickerItem *datePickerField = (APCTableViewDatePickerItem *)field;
                APCDefaultTableViewCell *defaultCell = (APCDefaultTableViewCell *)cell;
                
                if (datePickerField.date) {
                    NSString *dateWithFormat = [datePickerField.date toStringWithFormat:datePickerField.dateFormat];
                    defaultCell.detailTextLabel.text = dateWithFormat;
                    defaultCell.detailTextLabel.textColor = [UIColor appSecondaryColor1];
                } else {
                    defaultCell.detailTextLabel.text = field.placeholder;
                    defaultCell.detailTextLabel.textColor = [UIColor appSecondaryColor3];
                }
                
                
                if (field.textAlignnment == NSTextAlignmentRight) {
                    defaultCell.type = kAPCDefaultTableViewCellTypeRight;
                } else {
                    defaultCell.type = kAPCDefaultTableViewCellTypeLeft;
                }
                
                [self setupDefaultCellAppearance:defaultCell];
                
            }
            else if ([field isKindOfClass:[APCTableViewCustomPickerItem class]]) {
                
                APCTableViewCustomPickerItem *customPickerField = (APCTableViewCustomPickerItem *)field;
                APCDefaultTableViewCell *defaultCell = (APCDefaultTableViewCell *)cell;
                
                defaultCell.detailTextLabel.text = customPickerField.stringValue;
                
                if (field.textAlignnment == NSTextAlignmentRight) {
                    defaultCell.type = kAPCDefaultTableViewCellTypeRight;
                } else {
                    defaultCell.type = kAPCDefaultTableViewCellTypeLeft;
                }
                
                [self setupDefaultCellAppearance:defaultCell];
                
            } else if ([field isKindOfClass:[APCTableViewSegmentItem class]]) {
                
                APCTableViewSegmentItem *segmentPickerField = (APCTableViewSegmentItem *)field;
                APCSegmentedTableViewCell *segmentedCell = (APCSegmentedTableViewCell *)cell;
                segmentedCell.delegate = self;
                segmentedCell.selectedSegmentIndex = segmentPickerField.selectedIndex;
                segmentedCell.userInteractionEnabled = segmentPickerField.editable;
                
            } else {
                if (!cell) {
                    cell = [[UITableViewCell alloc] initWithStyle:field.style reuseIdentifier:field.identifier];
                }
            }
            
            if (self.isEditing && field.editable && !self.signUp) {
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.selectionStyle = UITableViewCellSelectionStyleGray;
            } else{
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
        }
        
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = tableView.rowHeight;
    
    if (self.isPickerShowing && (indexPath.row == self.pickerIndexPath.row)) {
        height = 164;
    }
    
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    APCTableViewItem *field;
    
    if (self.isPickerShowing && (indexPath.row > self.pickerIndexPath.row)) {
        field = self.items[indexPath.row - 1];
    } else{
        field = self.items[indexPath.row];
    }
    
    if (self.isEditing && field.isEditable && ([field isKindOfClass:[APCTableViewCustomPickerItem class]] ||
                             [field isKindOfClass:[APCTableViewDatePickerItem class]])) {
        
        [self.tableView endEditing:YES];
        [self handlePickerForIndexPath:indexPath];
        
    } else if ([field isKindOfClass:[APCTableViewTextFieldItem class]]){
        
        NSIndexPath *actualIndexPath = indexPath;
        
        if (self.pickerShowing) {
            if (indexPath.row > self.pickerIndexPath.row) {
                actualIndexPath = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section];
            }
            
            [self hidePickerCell];
        }
        
        if (self.isEditing) {
            APCTextFieldTableViewCell *cell = (APCTextFieldTableViewCell *)[tableView cellForRowAtIndexPath:actualIndexPath];
            [cell.textField becomeFirstResponder];
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - APCPickerTableViewCellDelegate methods

- (void)pickerTableViewCell:(APCPickerTableViewCell *)cell datePickerValueChanged:(NSDate *)date
{
    if (self.pickerShowing) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        
        APCTableViewDatePickerItem *field = self.items[indexPath.row - 1];
        field.date = date;
        
        NSString *dateWithFormat = [field.date toStringWithFormat:field.dateFormat];
        field.detailText = dateWithFormat;
        
        UITableViewCell *dateCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section]];
        dateCell.detailTextLabel.text = dateWithFormat;
    }
}

- (void)pickerTableViewCell:(APCPickerTableViewCell *)cell pickerViewDidSelectIndices:(NSArray *)selectedIndices
{
    if (self.pickerShowing) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        
        APCTableViewCustomPickerItem *field = self.items[indexPath.row - 1];
        field.selectedRowIndices = selectedIndices;
        
        UITableViewCell *dateCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section]];
        dateCell.detailTextLabel.text = field.stringValue;
    }
}

#pragma mark - APCTextFieldTableViewCellDelegate methods

- (void)textFieldTableViewCellDidBeginEditing:(APCTextFieldTableViewCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    NSIndexPath *actualIndexPath = indexPath;
    
    if (self.pickerShowing) {
        if (indexPath.row > self.pickerIndexPath.row) {
            actualIndexPath = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section];
        }
        
        [self hidePickerCell];
    }
}

- (void)textFieldTableViewCell:(APCTextFieldTableViewCell *)cell shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    NSString *text = [cell.textField.text stringByReplacingCharactersInRange:range withString:string];
    
    APCTableViewTextFieldItem *textFieldItem = self.items[indexPath.row];
    textFieldItem.value = text;
}

- (void)textFieldTableViewCellDidEndEditing:(APCTextFieldTableViewCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    APCTableViewTextFieldItem *textFieldItem = self.items[indexPath.row];
    textFieldItem.value = cell.textField.text;
}

- (void)textFieldTableViewCellDidReturn:(APCTextFieldTableViewCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    [self nextResponderForIndexPath:indexPath];
}

- (void)nextResponderForIndexPath:(NSIndexPath *)indexPath
{
    NSInteger lastRowIndex = [self.tableView numberOfRowsInSection:0] - 1;
    
    NSInteger currentRowIndex = -1;
    if (indexPath) {
        currentRowIndex = indexPath.row;
    }
    
    if (currentRowIndex < lastRowIndex) {
        
        NSInteger nextRowIndex = -1;
        
        for (NSInteger i = currentRowIndex + 1; i <= lastRowIndex; i++) {
            APCTableViewItem *field = self.items[i];
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

- (void)segmentedTableViewcell:(APCSegmentedTableViewCell *)cell didSelectSegmentAtIndex:(NSInteger)index
{
    if (self.pickerShowing) {
        [self hidePickerCell];
    }
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    APCTableViewSegmentItem *field = self.items[indexPath.row];
    field.selectedIndex = index;
}

#pragma mark - Private Methods

- (void)handlePickerForIndexPath:(NSIndexPath *)indexPath
{
    if (self.isPickerShowing && (self.pickerIndexPath.row - 1 == indexPath.row)) {
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
    
    self.pickerIndexPath = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:0];
    
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:@[self.pickerIndexPath]
                          withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
}

- (void)hidePickerCell
{
    self.pickerShowing = NO;
    
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.pickerIndexPath.row inSection:0]]
                          withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
    
    self.pickerIndexPath = nil;
}

- (NSIndexPath *)actualSelectedIndexPath:(NSIndexPath *)selectedIndexPath {
    
    NSIndexPath *newIndexPath;
    
    if (self.isPickerShowing && (self.pickerIndexPath.row < selectedIndexPath.row)){
        
        newIndexPath = [NSIndexPath indexPathForRow:selectedIndexPath.row - 1 inSection:0];
        
    }else {
        
        newIndexPath = [NSIndexPath indexPathForRow:selectedIndexPath.row  inSection:0];
        
    }
    
    return newIndexPath;
}

@end
