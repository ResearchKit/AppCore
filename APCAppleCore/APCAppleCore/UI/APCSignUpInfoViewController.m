//
//  APCSignUpGeneralInfoViewController.m
//  APCAppleCore
//
//  Created by Ramsundar Shandilya on 10/14/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCSignUpInfoViewController.h"
#import "APCTableViewItem.h"
#import "APCAppDelegate.h"
#import "APCUserInfoConstants.h"
#import "UIAlertView+Helper.h"
#import "APCStepProgressBar.h"
#import "NSBundle+Helper.h"
#import "NSString+Helper.h"
#import "NSDate+Helper.h"
#import "UIColor+APCAppearance.h"
#import "UIFont+APCAppearance.h"

@interface APCSignUpInfoViewController ()

@property (nonatomic, getter=isPickerShowing) BOOL pickerShowing;

@property (nonatomic, strong) NSIndexPath *pickerIndexPath;

@end

@implementation APCSignUpInfoViewController

@synthesize stepProgressBar;
@synthesize user = _user;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupStepProgressBar];
    [self setupAppearance];
    
    self.nameTextField.delegate = self;
    self.userNameTextField.delegate = self;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -

- (void)setupStepProgressBar
{
    self.stepProgressBar = [[APCStepProgressBar alloc] initWithFrame:CGRectMake(0, -kAPCSignUpProgressBarHeight, CGRectGetWidth(self.view.frame), kAPCSignUpProgressBarHeight)
                                                               style:APCStepProgressBarStyleOnlyProgressView];
    self.stepProgressBar.numberOfSteps = 4;
    [self.view addSubview:self.stepProgressBar];
    
    
    // Instead of reducing table view height, we can just adjust tableview scroll insets
    UIEdgeInsets inset = self.tableView.contentInset;
    inset.top += CGRectGetHeight(self.stepProgressBar.frame);
    
    self.tableView.contentInset = inset;
}

- (void)setStepNumber:(NSUInteger)stepNumber title:(NSString *)title
{
    NSString *step = [NSString stringWithFormat:NSLocalizedString(@"Step %i", @""), stepNumber];
    
    NSString *string = [NSString stringWithFormat:@"%@: %@", step, title];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    [attributedString setAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14]} range:NSMakeRange(0, string.length)];
    [attributedString setAttributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:14]} range:NSMakeRange(0, step.length)];
    
    self.stepProgressBar.leftLabel.attributedText = attributedString;
}

- (APCUser *) user {
    if (!_user) {
        _user = ((APCAppDelegate*) [UIApplication sharedApplication].delegate).dataSubstrate.currentUser;
    }
    
    return _user;
}

#pragma mark - Appearance

- (void)setupAppearance
{
    [self.nameTextField setTextColor:[UIColor appSecondaryColor1]];
    [self.nameTextField setFont:[UIFont appRegularFontWithSize:16.0f]];
    
    [self.userNameTextField setTextColor:[UIColor appSecondaryColor1]];
    [self.userNameTextField setFont:[UIFont appRegularFontWithSize:16.0f]];
    
    [self.profileImageButton.imageView.layer setCornerRadius:CGRectGetHeight(self.profileImageButton.bounds)/2];
    
    [self.footerLabel setTextColor:[UIColor appSecondaryColor3]];
    [self.footerLabel setFont:[UIFont appRegularFontWithSize:14.0f]];
}

- (void)setupPickerCellAppeareance:(APCPickerTableViewCell *)cell
{

}

- (void)setupTextFieldCellAppearance:(APCTextFieldTableViewCell *)cell
{
    [cell.textLabel setFont:[UIFont appRegularFontWithSize:14.0f]];
    [cell.textLabel setTextColor:[UIColor appSecondaryColor1]];
    
    [cell.textField setFont:[UIFont appRegularFontWithSize:17.0f]];
    [cell.textField setTextColor:[UIColor appSecondaryColor1]];
}

- (void)setupSegmentedCellAppearance:(APCSegmentedTableViewCell *)cell
{
    
}

- (void)setupDefaultCellAppearance:(UITableViewCell *)cell
{
    [cell.textLabel setFont:[UIFont appRegularFontWithSize:14.0f]];
    [cell.textLabel setTextColor:[UIColor appSecondaryColor1]];
    
    [cell.detailTextLabel setFont:[UIFont appRegularFontWithSize:17.0f]];
    [cell.detailTextLabel setTextColor:[UIColor appSecondaryColor1]];
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
            
            if ([field isKindOfClass:[APCTableViewTextFieldItem class]]) {
                
                APCTableViewTextFieldItem *textFieldItem = (APCTableViewTextFieldItem *)field;
                APCTextFieldTableViewCell *textFieldCell = (APCTextFieldTableViewCell *)cell;
                
                textFieldCell.textField.placeholder = textFieldItem.placeholder;
                textFieldCell.textField.text = textFieldItem.value;
                textFieldCell.textField.secureTextEntry = textFieldItem.isSecure;
                textFieldCell.textField.keyboardType = textFieldItem.keyboardType;
                textFieldCell.textField.returnKeyType = textFieldItem.returnKeyType;
                textFieldCell.textField.clearButtonMode = textFieldItem.clearButtonMode;
                
                textFieldCell.textLabel.text = textFieldItem.value;
                
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
                
                if (!cell) {
                    cell = [[UITableViewCell alloc] initWithStyle:field.style reuseIdentifier:field.identifier];
                }
                
                APCTableViewDatePickerItem *datePickerField = (APCTableViewDatePickerItem *)field;
                
                NSString *dateWithFormat = [datePickerField.date toStringWithFormat:datePickerField.dateFormat];
                cell.detailTextLabel.text = dateWithFormat;
                
            }
            else if ([field isKindOfClass:[APCTableViewCustomPickerItem class]]) {
                if (!cell) {
                    cell = [[UITableViewCell alloc] initWithStyle:field.style reuseIdentifier:field.identifier];
                }
                
                APCTableViewCustomPickerItem *customPickerField = (APCTableViewCustomPickerItem *)field;
                cell.detailTextLabel.text = customPickerField.stringValue;
                
            } else if ([field isKindOfClass:[APCTableViewSegmentItem class]]) {
                if (!cell) {
                    cell = [[APCSegmentedTableViewCell alloc] initWithStyle:field.style reuseIdentifier:field.identifier];
                }
                
                APCTableViewSegmentItem *segmentPickerField = (APCTableViewSegmentItem *)field;
                APCSegmentedTableViewCell *segmentedCell = (APCSegmentedTableViewCell *)cell;
                segmentedCell.delegate = self;
                segmentedCell.selectedSegmentIndex = segmentPickerField.selectedIndex;
                
            } else {
                if (!cell) {
                    cell = [[UITableViewCell alloc] initWithStyle:field.style reuseIdentifier:field.identifier];
                }
            }
            
            cell.selectionStyle = field.selectionStyle;
            cell.textLabel.text = field.caption;
            cell.detailTextLabel.text = field.detailText;
            
            [self setupDefaultCellAppearance:cell];
            
            if (self.isEditing) {
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            } else{
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
        
    }
    
    return cell;
}

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
    
    if ([field isKindOfClass:[APCTableViewCustomPickerItem class]] ||
        [field isKindOfClass:[APCTableViewDatePickerItem class]]) {
        [self.tableView endEditing:YES];
        [self handlePickerForIndexPath:indexPath];
    } else if ([field isKindOfClass:[APCTableViewTextFieldItem class]]){
        APCTextFieldTableViewCell *cell = (APCTextFieldTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        [cell.textField becomeFirstResponder];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UITextFieldDelegate methods

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    
    if ((textField == self.nameTextField) && self.userNameTextField) {
        [self.userNameTextField becomeFirstResponder];
    } else {
        [self nextResponderForIndexPath:nil];
    }
    
    return YES;
}

#pragma mark - APCPickerTableViewCellDelegate methods

- (void)pickerTableViewCell:(APCPickerTableViewCell *)cell datePickerValueChanged:(NSDate *)date
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    APCTableViewDatePickerItem *field = self.items[indexPath.row - 1];
    field.date = date;
    
    NSString *dateWithFormat = [field.date toStringWithFormat:field.dateFormat];
    field.detailText = dateWithFormat;
    
    UITableViewCell *dateCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section]];
    dateCell.detailTextLabel.text = dateWithFormat;
}

- (void)pickerTableViewCell:(APCPickerTableViewCell *)cell pickerViewDidSelectIndices:(NSArray *)selectedIndices
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    APCTableViewCustomPickerItem *field = self.items[indexPath.row - 1];
    field.selectedRowIndices = selectedIndices;
    
    UITableViewCell *dateCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section]];
    dateCell.detailTextLabel.text = field.stringValue;
}

#pragma mark - APCTextFieldTableViewCellDelegate methods

- (void)textFieldTableViewCellDidBecomeFirstResponder:(APCTextFieldTableViewCell *)cell
{
    
}

- (void)textFieldTableViewCellDidReturn:(APCTextFieldTableViewCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    APCTableViewTextFieldItem *textFieldItem = self.items[indexPath.row];
    textFieldItem.value = cell.textField.text;
    
    [self nextResponderForIndexPath:indexPath];
}

- (void)nextResponderForIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger lastRowIndex = [self.tableView numberOfRowsInSection:0] - 1;
    
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
        
        if (nextRowIndex > 0) {
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
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    APCTableViewSegmentItem *field = self.items[indexPath.row];
    field.selectedIndex = index;
}

#pragma mark - UIImagePickerControllerDelegate

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = info[UIImagePickerControllerEditedImage];
    if (!image) {
        image = info[UIImagePickerControllerOriginalImage];
    }
    
    [self.profileImageButton setImage:image forState:UIControlStateNormal];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private Methods

- (void)handlePickerForIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView beginUpdates];
    
    if (self.isPickerShowing && (self.pickerIndexPath.row - 1 == indexPath.row)) {
        [self hidePickerCell];
    } else{
        NSIndexPath *selectedIndexpath = [self actualSelectedIndexPath:indexPath];
        
        if (self.isPickerShowing) {
            [self hidePickerCell];
        }
        
        [self showPickerAtIndex:selectedIndexpath];
    }
    
    [self.tableView endUpdates];
    
}

- (void)showPickerAtIndex:(NSIndexPath *)indexPath {
    
    self.pickerShowing = YES;
    
    self.pickerIndexPath = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:0];
    
    [self.tableView insertRowsAtIndexPaths:@[self.pickerIndexPath]
                          withRowAnimation:UITableViewRowAnimationFade];
}

- (void)hidePickerCell
{
    self.pickerShowing = NO;
    
    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.pickerIndexPath.row inSection:0]]
                          withRowAnimation:UITableViewRowAnimationFade];
    
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

#pragma mark - Private Methods

- (BOOL) isContentValid:(NSString **)errorMessage {
    BOOL isContentValid = YES;
    
    if (self.tableView.tableHeaderView) {
        if (![self.nameTextField.text isValidForRegex:kAPCUserInfoFieldNameRegEx]) {
            isContentValid = NO;
            
            if (errorMessage) {
                *errorMessage = NSLocalizedString(@"Please give a valid first name", @"");
            }
        } else if (![self.userNameTextField.text isValidForRegex:kAPCGeneralInfoItemUserNameRegEx]){
            isContentValid = NO;
            
            if (errorMessage) {
                *errorMessage = NSLocalizedString(@"Please give a valid Username", @"");
            }
        }
    }
    
    return isContentValid;
}

- (void)next{
    
}


@end
