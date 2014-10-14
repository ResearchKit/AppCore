//
//  APCProfileViewController.m
//  APCAppleCore
//
//  Created by Ramsundar Shandilya on 10/10/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCProfileViewController.h"
#import "APCTableViewItem.h"
#import "APCAppDelegate.h"
#import "NSDate+Helper.h"
#import "APCUserInfoConstants.h"

static NSString * const kAPCProfileTableViewCellIdentifier   = @"APCProfileTableViewCell";

@interface APCProfileViewController () 

@property (nonatomic, getter=isEditing) BOOL editing;

@property (nonatomic, getter=isPickerShowing) BOOL pickerShowing;

@property (nonatomic, strong) NSIndexPath *pickerIndexPath;

@end

@implementation APCProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self prepareFields];
    [self.tableView reloadData];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    self.tableView.tableHeaderView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 127);

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareFields
{
    self.items = [NSMutableArray new];
    self.itemTypeOrder = [NSMutableArray new];
    
    {
        APCTableViewItem *field = [APCTableViewItem new];
        field.caption = NSLocalizedString(@"Email", @"");
        field.identifier = kAPCProfileTableViewCellIdentifier;
        field.editable = NO;
        [self.items addObject:field];
        [self.itemTypeOrder addObject:@(APCSignUpUserInfoItemEmail)];
    }
    
    {
        APCTableViewItem *field = [APCTableViewItem new];
        field.caption = NSLocalizedString(@"Birthdate", @"");
        field.identifier = kAPCProfileTableViewCellIdentifier;
        field.editable = NO;
        [self.items addObject:field];
        [self.itemTypeOrder addObject:@(APCSignUpUserInfoItemDateOfBirth)];
    }
    
    {
        APCTableViewItem *field = [APCTableViewItem new];
        field.caption = NSLocalizedString(@"Biological Sex", @"");
        field.identifier = kAPCProfileTableViewCellIdentifier;
        field.editable = NO;
        [self.items addObject:field];
        [self.itemTypeOrder addObject:@(APCSignUpUserInfoItemGender)];
    }
    
    {
        APCTableViewCustomPickerItem *field = [APCTableViewCustomPickerItem new];
        field.caption = NSLocalizedString(@"Medical Conditions", @"");
        field.pickerData = @[[APCUser medicalConditions]];
        field.identifier = kAPCProfileTableViewCellIdentifier;
        
        if (self.user.medications) {
            field.selectedRowIndices = @[ @([field.pickerData[0] indexOfObject:self.user.medicalConditions]) ];
        }
        else {
            field.selectedRowIndices = @[ @(0) ];
        }
        
        [self.items addObject:field];
        [self.itemTypeOrder addObject:@(APCSignUpUserInfoItemMedicalCondition)];
    }
    
    {
        APCTableViewCustomPickerItem *field = [APCTableViewCustomPickerItem new];
        field.caption = NSLocalizedString(@"Medication", @"");
        field.pickerData = @[[APCUser medications]];
        field.identifier = kAPCProfileTableViewCellIdentifier;
        
        if (self.user.medications) {
            field.selectedRowIndices = @[ @([field.pickerData[0] indexOfObject:self.user.medications]) ];
        }
        else {
            field.selectedRowIndices = @[ @(0) ];
        }
        
        [self.items addObject:field];
        [self.itemTypeOrder addObject:@(APCSignUpUserInfoItemMedication)];
    }
    
    {
        APCTableViewCustomPickerItem *field = [APCTableViewCustomPickerItem new];
        field.caption = NSLocalizedString(@"Height", @"");
        field.pickerData = [APCUser heights];
        field.identifier = kAPCProfileTableViewCellIdentifier;
        
        if (self.user.height) {
            double heightInInches = [APCUser heightInInches:self.user.height];
            NSString *feet = [NSString stringWithFormat:@"%d'", (int)heightInInches/12];
            NSString *inches = [NSString stringWithFormat:@"%d''", (int)heightInInches%12];
            
            field.selectedRowIndices = @[ @([field.pickerData[0] indexOfObject:feet]), @([field.pickerData[1] indexOfObject:inches]) ];
        }
        else {
            field.selectedRowIndices = @[ @(2), @(5) ];
        }
        
        [self.items addObject:field];
        [self.itemTypeOrder addObject:@(APCSignUpUserInfoItemHeight)];
    }
    
    {
        APCTableViewTextFieldItem *field = [APCTableViewTextFieldItem new];
        field.caption = NSLocalizedString(@"Weight", @"");
        field.placeholder = NSLocalizedString(@"lb", @"");
        field.regularExpression = kAPCMedicalInfoItemWeightRegEx;
        field.value = [NSString stringWithFormat:@"%.1f", [APCUser weightInPounds:self.user.weight]];
        field.keyboardType = UIKeyboardTypeNumberPad;
        field.textAlignnment = NSTextAlignmentRight;
        field.identifier = kAPCTextFieldTableViewCellIdentifier;
        
        [self.items addObject:field];
        [self.itemTypeOrder addObject:@(APCSignUpUserInfoItemWeight)];
    }
    
    {
        APCTableViewDatePickerItem *field = [APCTableViewDatePickerItem new];
        field.selectionStyle = UITableViewCellSelectionStyleGray;
        field.style = UITableViewCellStyleValue1;
        field.caption = NSLocalizedString(@"What time do you wake up?", @"");
        field.placeholder = NSLocalizedString(@"7:00 AM", @"");
        field.identifier = NSStringFromClass([APCTableViewDatePickerItem class]);
        field.datePickerMode = UIDatePickerModeTime;
        field.dateFormat = kAPCMedicalInfoItemSleepTimeFormat;
        field.detailDiscloserStyle = YES;
        
        if (self.user.sleepTime) {
            field.date = self.user.sleepTime;
        }
        
        [self.items addObject:field];
        [self.itemTypeOrder addObject:@(APCSignUpUserInfoItemWakeUpTime)];
    }
    
    {
        APCTableViewDatePickerItem *field = [APCTableViewDatePickerItem new];
        field.selectionStyle = UITableViewCellSelectionStyleGray;
        field.style = UITableViewCellStyleValue1;
        field.caption = NSLocalizedString(@"What time do you go to sleep?", @"");
        field.placeholder = NSLocalizedString(@"9:30 PM", @"");
        field.identifier = NSStringFromClass([APCTableViewDatePickerItem class]);
        field.datePickerMode = UIDatePickerModeTime;
        field.dateFormat = kAPCMedicalInfoItemSleepTimeFormat;
        field.detailDiscloserStyle = YES;
        
        if (self.user.wakeUpTime) {
            field.date = self.user.wakeUpTime;
        }
        
        [self.items addObject:field];
        [self.itemTypeOrder addObject:@(APCSignUpUserInfoItemSleepTime)];
    }
    
}

#pragma mark - Getter Methods

- (APCUser *) user {
    if (!_user) {
        _user = ((APCAppDelegate *)[UIApplication sharedApplication].delegate).dataSubstrate.currentUser;
    }
    
    return _user;
}

#pragma mark - UITableViewDataSource

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
        if (!cell) {
            cell = [[APCPickerTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kAPCPickerTableViewCellIdentifier];
        }
        
        APCTableViewItem *field = self.items[indexPath.row - 1];
        
        APCPickerTableViewCell *pickerCell = (APCPickerTableViewCell *)cell;
        
        if ([field isKindOfClass:[APCTableViewDatePickerItem class]]) {
            
            APCTableViewDatePickerItem *datePickerField = (APCTableViewDatePickerItem *)field;
            
            pickerCell.type = kAPCPickerCellTypeDate;
            pickerCell.datePicker.datePickerMode = datePickerField.datePickerMode;
            pickerCell.delegate = self;
            
            
        } else if ([field isKindOfClass:[APCTableViewCustomPickerItem class]]){
            
            APCTableViewCustomPickerItem *customPickerField = (APCTableViewCustomPickerItem *)field;
            pickerCell.type = kAPCPickerCellTypeCustom;
            pickerCell.pickerValues = customPickerField.pickerData;
            [pickerCell.pickerView reloadAllComponents];
            pickerCell.delegate = self;
        }
        
    } else {
        APCTableViewItem *field = self.items[indexPath.row];
        
        if (field) {
            
            cell = [tableView dequeueReusableCellWithIdentifier:field.identifier];
            
            if ([field isKindOfClass:[APCTableViewTextFieldItem class]]) {
                
                if (!cell) {
                    cell = [[APCTextFieldTableViewCell alloc] initWithStyle:field.style reuseIdentifier:field.identifier];
                }
                
                APCTableViewTextFieldItem *textFieldItem = (APCTableViewTextFieldItem *)field;
                APCTextFieldTableViewCell *textFieldCell = (APCTextFieldTableViewCell *)cell;
                
                textFieldCell.textField.placeholder = textFieldItem.placeholder;
                textFieldCell.textField.text = textFieldItem.value;
                textFieldCell.textField.secureTextEntry = textFieldItem.isSecure;
                textFieldCell.textField.keyboardType = textFieldItem.keyboardType;
                textFieldCell.textField.returnKeyType = textFieldItem.returnKeyType;
                textFieldCell.textField.clearButtonMode = textFieldItem.clearButtonMode;
                
                textFieldCell.textLabel.text = textFieldItem.value;
                
                textFieldCell.type = kAPCTextFieldCellTypeRight;
                textFieldCell.delegate = self;
                
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
                
            } else {
                if (!cell) {
                    cell = [[UITableViewCell alloc] initWithStyle:field.style reuseIdentifier:field.identifier];
                }
            }
            
            cell.selectionStyle = field.selectionStyle;
            cell.textLabel.text = field.caption;
            cell.detailTextLabel.text = field.detailText;
            
            if (self.isEditing) {
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
    
    if ([field isKindOfClass:[APCTableViewCustomPickerItem class]] ||
        [field isKindOfClass:[APCTableViewDatePickerItem class]]) {
        [self handlePickerForIndexPath:indexPath];
    } else if ([field isKindOfClass:[APCTableViewTextFieldItem class]]){
        
    }
         
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - APCPickerTableViewCellDelegate methods

- (void)pickerTableViewCell:(APCPickerTableViewCell *)cell datePickerValueChanged:(NSDate *)date
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    APCTableViewDatePickerItem *field = self.items[indexPath.row - 1];
    field.date = date;
    
    NSString *dateWithFormat = [field.date toStringWithFormat:field.dateFormat];
    
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

#pragma mark - IBActions

- (IBAction)signOut:(id)sender
{
    
}

- (IBAction)leaveStudy:(id)sender
{
    
}

- (IBAction)reviewConsent:(id)sender
{
    
}

- (IBAction)changeProfileImage:(id)sender
{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.editing = YES;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else {
        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    imagePickerController.delegate = self;
    [self presentViewController:imagePickerController animated:YES completion:nil];

}

- (IBAction)editFields:(UIBarButtonItem *)sender {
    if (self.isEditing) {
        sender.title = NSLocalizedString(@"Done", @"Done");
        sender.style = UIBarButtonItemStyleDone;
    } else{
        sender.title = NSLocalizedString(@"Edit", @"Edit");
        sender.style = UIBarButtonItemStylePlain;
    }
    
    self.editing = !self.editing;
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
