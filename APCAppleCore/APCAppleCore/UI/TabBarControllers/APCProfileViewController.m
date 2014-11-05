//
//  APCProfileViewController.m
//  APCAppleCore
//
//  Created by Ramsundar Shandilya on 10/10/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCProfileViewController.h"
#import "APCAppleCore.h"
#import "APCTableViewItem.h"
#import "APCAppDelegate.h"
#import "APCUserInfoConstants.h"

#import "UIColor+APCAppearance.h"
#import "UIFont+APCAppearance.h"
#import "NSDate+Helper.h"

@interface APCProfileViewController ()<RKTaskViewControllerDelegate>

@property (nonatomic, getter=isEditing) BOOL editing;

@property (nonatomic, getter=isPickerShowing) BOOL pickerShowing;

@property (nonatomic, strong) NSIndexPath *pickerIndexPath;

@end

@implementation APCProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupAppearance];
    
    self.firstNameTextField.delegate = self;
    self.lastNameTextField.delegate = self;

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    CGRect headerRect = self.headerView.frame;
    headerRect.size.height = 127.0f;
    self.headerView.frame = headerRect;
    
    self.tableView.tableHeaderView = self.tableView.tableHeaderView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Getter Methods

- (APCUser *) user {
    if (!_user) {
        _user = ((APCAppDelegate *)[UIApplication sharedApplication].delegate).dataSubstrate.currentUser;
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
    
    [self.editLabel setTextColor:[UIColor appSecondaryColor1]];
    [self.editLabel setFont:[UIFont appRegularFontWithSize:14.0f]];
    
    [self.footerTitleLabel setTextColor:[UIColor appSecondaryColor2]];
    [self.footerTitleLabel setFont:[UIFont appRegularFontWithSize:14.0f]];
    
    [self.editLabel setTextColor:[UIColor appSecondaryColor1]];
    [self.editLabel setFont:[UIFont appRegularFontWithSize:14.0f]];
    
    [self.editLabel setTextColor:[UIColor appSecondaryColor1]];
    [self.editLabel setFont:[UIFont appRegularFontWithSize:14.0f]];
    
    [self.diseaseLabel setTextColor:[UIColor appPrimaryColor]];
    [self.diseaseLabel setFont:[UIFont appRegularFontWithSize:16.0f]];
    
    [self.dateRangeLabel setTextColor:[UIColor appSecondaryColor3]];
    [self.dateRangeLabel setFont:[UIFont appLightFontWithSize:16.0f]];
    
    [self.reviewConsentButton setBackgroundColor:[UIColor appPrimaryColor]];
    [self.reviewConsentButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.reviewConsentButton.titleLabel setFont:[UIFont appMediumFontWithSize:19.0]];
    
    [self.signOutButton setTitleColor:[UIColor appPrimaryColor] forState:UIControlStateNormal];
    [self.signOutButton.titleLabel setFont:[UIFont appRegularFontWithSize:16.0]];
    
    [self.leaveStudyButton setTitleColor:[UIColor appPrimaryColor] forState:UIControlStateNormal];
    [self.leaveStudyButton.titleLabel setFont:[UIFont appRegularFontWithSize:16.0]];
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


- (void)setupDefaultCellAppearance:(APCDefaultTableViewCell *)cell
{
    [cell.textLabel setFont:[UIFont appRegularFontWithSize:14.0f]];
    [cell.textLabel setTextColor:[UIColor appSecondaryColor1]];
    
    [cell.detailTextLabel setFont:[UIFont appRegularFontWithSize:17.0f]];
    [cell.detailTextLabel setTextColor:[UIColor appSecondaryColor1]];
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
                
                NSString *dateWithFormat = [datePickerField.date toStringWithFormat:datePickerField.dateFormat];
                cell.detailTextLabel.text = dateWithFormat;
                
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
                
                cell.detailTextLabel.text = customPickerField.stringValue;
                
                if (field.textAlignnment == NSTextAlignmentRight) {
                    defaultCell.type = kAPCDefaultTableViewCellTypeRight;
                } else {
                    defaultCell.type = kAPCDefaultTableViewCellTypeLeft;
                }
                
                [self setupDefaultCellAppearance:defaultCell];
                
            } else {
                if (!cell) {
                    cell = [[UITableViewCell alloc] initWithStyle:field.style reuseIdentifier:field.identifier];
                }
            }
            
            if (self.isEditing && field.editable) {
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
    
    if (self.isEditing && ([field isKindOfClass:[APCTableViewCustomPickerItem class]] ||
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

#pragma mark - UIImagePickerControllerDelegate

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = info[UIImagePickerControllerEditedImage];
    if (!image) {
        image = info[UIImagePickerControllerOriginalImage];
    }
    
    self.profileImage = image;
    [self.profileImageButton setImage:image forState:UIControlStateNormal];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
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

#pragma mark - Public methods

- (void)loadProfileValuesInModel
{
    
}

- (void)setupDataFromJSONFile:(NSString *)jsonFileName
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:jsonFileName ofType:@"json"];
    NSString *JSONString = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
    
    NSError *parseError;
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:[JSONString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&parseError];
    
    if (!parseError) {
        
        self.diseaseLabel.text = jsonDictionary[@"disease_name"];
    }
}

#pragma mark - Consent

- (void)showConsent
{
    RKConsentDocument* consent = [[RKConsentDocument alloc] init];
    consent.title = @"Demo Consent";
    consent.signaturePageTitle = @"Consent";
    consent.signaturePageContent = @"I agree  to participate in this research Study.";
    
    
    RKConsentSignature *participantSig = [RKConsentSignature signatureForPersonWithTitle:@"Participant" name:nil signatureImage:nil dateString:nil];
    [consent addSignature:participantSig];
    
    RKConsentSignature *investigatorSig = [RKConsentSignature signatureForPersonWithTitle:@"Investigator" name:@"Jake Clemson" signatureImage:[UIImage imageNamed:@"signature.png"] dateString:@"9/2/14"];
    [consent addSignature:investigatorSig];
    
    
    
    
    NSMutableArray* components = [NSMutableArray new];
    
    NSArray* scenes = @[@(RKConsentSectionTypeOverview),
                        @(RKConsentSectionTypeActivity),
                        @(RKConsentSectionTypeSensorData),
                        @(RKConsentSectionTypeDeIdentification),
                        @(RKConsentSectionTypeCombiningData),
                        @(RKConsentSectionTypeUtilizingData),
                        @(RKConsentSectionTypeImpactLifeTime),
                        @(RKConsentSectionTypePotentialRiskUncomfortableQuestion),
                        @(RKConsentSectionTypePotentialRiskSocial),
                        @(RKConsentSectionTypeAllowWithdraw)];
    for (NSNumber* type in scenes) {
        RKConsentSection* c = [[RKConsentSection alloc] initWithType:type.integerValue];
        c.content = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam adhuc, meo fortasse vitio, quid ego quaeram non perspicis. Plane idem, inquit, et maxima quidem, qua fieri nulla maior potest. Quonam, inquit, modo? An potest, inquit ille, quicquam esse suavius quam nihil dolere? Cave putes quicquam esse verius. Quonam, inquit, modo?";
        [components addObject:c];
    }
    
    {
        RKConsentSection* c = [[RKConsentSection alloc] initWithType:RKConsentSectionTypeCustom];
        c.summary = @"Custom Scene summary";
        c.title = @"Custom Scene";
        c.content = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam adhuc, meo fortasse vitio, quid ego quaeram non perspicis. Plane idem, inquit, et maxima quidem, qua fieri nulla maior potest. Quonam, inquit, modo? An potest, inquit ille, quicquam esse suavius quam nihil dolere? Cave putes quicquam esse verius. Quonam, inquit, modo?";
        c.customImage = [UIImage imageNamed:@"image_example.png"];
        [components addObject:c];
    }
    
    {
        RKConsentSection* c = [[RKConsentSection alloc] initWithType:RKConsentSectionTypeOnlyInDocument];
        c.summary = @"OnlyInDocument Scene summary";
        c.title = @"OnlyInDocument Scene";
        c.content = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam adhuc, meo fortasse vitio, quid ego quaeram non perspicis. Plane idem, inquit, et maxima quidem, qua fieri nulla maior potest. Quonam, inquit, modo? An potest, inquit ille, quicquam esse suavius quam nihil dolere? Cave putes quicquam esse verius. Quonam, inquit, modo?";
        [components addObject:c];
    }
    
    consent.sections = [components copy];
    
    RKVisualConsentStep *step = [[RKVisualConsentStep alloc] initWithDocument:consent];
    RKConsentReviewStep *reviewStep = [[RKConsentReviewStep alloc] initWithSignature:participantSig inDocument:consent];
    RKTask *task = [[RKTask alloc] initWithName:@"consent" identifier:@"consent" steps:@[step,reviewStep]];
    RKTaskViewController *consentVC = [[RKTaskViewController alloc] initWithTask:task taskInstanceUUID:[NSUUID UUID]];
    
    consentVC.taskDelegate = self;
    [self presentViewController:consentVC animated:YES completion:nil];
    
}

#pragma mark - TaskViewController Delegate methods

- (void)taskViewControllerDidComplete: (RKTaskViewController *)taskViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)taskViewControllerDidCancel:(RKTaskViewController *)taskViewController
{
    [taskViewController suspend];
    [taskViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - IBActions

- (IBAction)signOut:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:APCUserLogOutNotification object:self];
}

- (IBAction)leaveStudy:(id)sender
{
    
}

- (IBAction)reviewConsent:(id)sender
{
    [self showConsent];
}

- (IBAction)changeProfileImage:(id)sender
{
    if (self.isEditing) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Take Photo", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
            imagePickerController.editing = YES;
            imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            imagePickerController.delegate = self;
            [self presentViewController:imagePickerController animated:YES completion:nil];
        }];
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            [alertController addAction:cameraAction];
        }
        
        UIAlertAction *libraryAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Choose from Library", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
            imagePickerController.editing = YES;
            imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            imagePickerController.delegate = self;
            [self presentViewController:imagePickerController animated:YES completion:nil];
        }];
        [alertController addAction:libraryAction];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            
        }];
        [alertController addAction:cancelAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }    

}

- (IBAction)editFields:(UIBarButtonItem *)sender {
    
    if (self.isEditing) {
        
        if (self.isPickerShowing) {
            [self hidePickerCell];
        }
        
        sender.title = NSLocalizedString(@"Edit", @"Edit");
        sender.style = UIBarButtonItemStylePlain;
        
        [self loadProfileValuesInModel];
    } else{
        
        sender.title = NSLocalizedString(@"Done", @"Done");
        sender.style = UIBarButtonItemStyleDone;
    }
    
    self.editing = !self.editing;
    
    self.firstNameTextField.enabled = self.isEditing;
    self.lastNameTextField.enabled = self.isEditing;
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
