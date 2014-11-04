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
#import "UIAlertController+Helper.h"
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
    [self setupNavAppearance];
    
    self.firstNameTextField.delegate = self;
    self.lastNameTextField.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.headerView) {
        CGRect headerRect = self.headerView.frame;
        headerRect.size.height = 127.0f;
        self.headerView.frame = headerRect;
        
        self.tableView.tableHeaderView = self.tableView.tableHeaderView;
    }    
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
    [self.firstNameTextField setTextColor:[UIColor appSecondaryColor1]];
    [self.firstNameTextField setFont:[UIFont appRegularFontWithSize:16.0f]];
    
    [self.lastNameTextField setTextColor:[UIColor appSecondaryColor1]];
    [self.lastNameTextField setFont:[UIFont appRegularFontWithSize:16.0f]];
    
    [self.profileImageButton.imageView.layer setCornerRadius:CGRectGetHeight(self.profileImageButton.bounds)/2];
    
    [self.footerLabel setTextColor:[UIColor appSecondaryColor3]];
    [self.footerLabel setFont:[UIFont appRegularFontWithSize:14.0f]];
    
}

- (void)setupNavAppearance
{
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 0, 44, 44);
    [backButton setImage:[UIImage imageNamed:@"back_button"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [self.navigationItem setLeftBarButtonItem:backBarButton];
}

#pragma mark - Custom Methods

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

- (void)setupDefaultCellAppearance:(APCDefaultTableViewCell *)cell
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
            
            if (self.isEditing && field.editable) {
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            } else{
                cell.accessoryType = UITableViewCellAccessoryNone;
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
    
    if (field.isEditable && ([field isKindOfClass:[APCTableViewCustomPickerItem class]] ||
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
        
        APCTextFieldTableViewCell *cell = (APCTextFieldTableViewCell *)[tableView cellForRowAtIndexPath:actualIndexPath];
        [cell.textField becomeFirstResponder];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UITextFieldDelegate methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (textField == self.firstNameTextField) {
        self.user.firstName = text;
    } else if (textField == self.lastNameTextField){
        self.user.lastName = text;
    }
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == self.firstNameTextField) {
        self.user.firstName = textField.text;
    } else if (textField == self.lastNameTextField){
        self.user.lastName = textField.text;
    }
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    
    if ((textField == self.firstNameTextField) && self.lastNameTextField) {
        [self.lastNameTextField becomeFirstResponder];
    } else {
        [self nextResponderForIndexPath:nil];
    }
    
    return YES;
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

- (void)showPickerAtIndex:(NSIndexPath *)indexPath {
    
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

#pragma mark - Private Methods

- (BOOL) isContentValid:(NSString **)errorMessage {
    
    BOOL isContentValid = YES;
    
    if (self.tableView.tableHeaderView) {
        if (![self.firstNameTextField.text isValidForRegex:kAPCUserInfoFieldNameRegEx]) {
            isContentValid = NO;
            
            if (errorMessage) {
                *errorMessage = NSLocalizedString(@"Please enter a valid first name.", @"");
            }
        } else if (![self.lastNameTextField.text isValidForRegex:kAPCUserInfoFieldNameRegEx]){
            isContentValid = NO;
            
            if (errorMessage) {
                *errorMessage = NSLocalizedString(@"Please enter a valid last name.", @"");
            }
        }
    }
    
    return isContentValid;
}

- (void)next{
    
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
