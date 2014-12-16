// 
//  APCProfileViewController.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "APCProfileViewController.h"
#import "APCAppCore.h"
#import "APCTableViewItem.h"
#import "APCAppDelegate.h"
#import "APCUserInfoConstants.h"
#import "APCConstants.h"

#import "UIColor+APCAppearance.h"
#import "UIFont+APCAppearance.h"
#import "NSDate+Helper.h"
#import "NSBundle+Helper.h"
#import "APCWithdrawCompleteViewController.h"
#import "APCSettingsViewController.h"
#import "APCUser+UserData.h"

static CGFloat kSectionHeaderHeight = 40.f;

@interface APCProfileViewController ()


@end

@implementation APCProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupAppearance];
    
    self.firstNameTextField.delegate = self;
    self.lastNameTextField.delegate = self;
    
    [self.profileImageButton.imageView setContentMode:UIViewContentModeScaleAspectFill];
    
    self.items = [self prepareContent];
    [self.tableView reloadData];
    
    self.firstNameTextField.text = self.user.firstName;
    self.firstNameTextField.enabled = NO;
    
    self.lastNameTextField.text = self.user.lastName;
    self.lastNameTextField.enabled = NO;
    
    self.profileImage = [UIImage imageWithData:self.user.profileImage];
    if (self.profileImage) {
        [self.profileImageButton setImage:self.profileImage forState:UIControlStateNormal];
    } else {
        [self.profileImageButton setImage:[UIImage imageNamed:@"profilePlaceholder"] forState:UIControlStateNormal];
    }
    
    
    [self setupDataFromJSONFile:@"StudyOverview"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    CGRect headerRect = self.headerView.frame;
    headerRect.size.height = 127.0f;
    self.headerView.frame = headerRect;
    
    self.tableView.tableHeaderView = self.tableView.tableHeaderView;
  APCLogViewControllerAppeared();
}

#pragma mark - Prepare Content

- (NSArray *)prepareContent
{
    NSDictionary *initialOptions = ((APCAppDelegate *)[UIApplication sharedApplication].delegate).initializationOptions;
    NSArray *profileElementsList = initialOptions[kAppProfileElementsListKey];
    
    NSMutableArray *items = [NSMutableArray new];
    
    {
        NSMutableArray *rowItems = [NSMutableArray new];
        
        for (NSNumber *type in profileElementsList) {
            
            APCUserInfoItemType itemType = type.integerValue;
            
            switch (itemType) {
                case kAPCUserInfoItemTypeEmail:
                {
                    APCTableViewItem *field = [APCTableViewItem new];
                    field.caption = NSLocalizedString(@"Email", @"");
                    field.identifier = kAPCDefaultTableViewCellIdentifier;
                    field.editable = NO;
                    field.textAlignnment = NSTextAlignmentLeft;
                    field.detailText = self.user.email;
                    
                    APCTableViewRow *row = [APCTableViewRow new];
                    row.item = field;
                    row.itemType = kAPCUserInfoItemTypeEmail;
                    [rowItems addObject:row];
                }
                    break;
                case kAPCUserInfoItemTypeBiologicalSex:
                {
                    APCTableViewItem *field = [APCTableViewItem new];
                    field.caption = NSLocalizedString(@"Biological Sex", @"");
                    field.identifier = kAPCDefaultTableViewCellIdentifier;
                    field.editable = NO;
                    field.textAlignnment = NSTextAlignmentRight;
                    field.detailText = [APCUser stringValueFromSexType:self.user.biologicalSex];
                    
                    APCTableViewRow *row = [APCTableViewRow new];
                    row.item = field;
                    row.itemType = kAPCUserInfoItemTypeBiologicalSex;
                    [rowItems addObject:row];
                }
                    break;
                case kAPCUserInfoItemTypeDateOfBirth:
                {
                    APCTableViewItem *field = [APCTableViewItem new];
                    field.caption = NSLocalizedString(@"Birthdate", @"");
                    field.identifier = kAPCDefaultTableViewCellIdentifier;
                    field.editable = NO;
                    field.textAlignnment = NSTextAlignmentRight;
                    field.detailText = [self.user.birthDate toStringWithFormat:NSDateDefaultDateFormat];
                    
                    APCTableViewRow *row = [APCTableViewRow new];
                    row.item = field;
                    row.itemType = kAPCUserInfoItemTypeDateOfBirth;
                    [rowItems addObject:row];

                }
                    break;
                case kAPCUserInfoItemTypeMedicalCondition:
                {
                    APCTableViewCustomPickerItem *field = [APCTableViewCustomPickerItem new];
                    field.caption = NSLocalizedString(@"Medical Conditions", @"");
                    field.pickerData = @[[APCUser medicalConditions]];
                    field.textAlignnment = NSTextAlignmentRight;
                    field.identifier = kAPCDefaultTableViewCellIdentifier;
                    
                    if (self.user.medications) {
                        field.selectedRowIndices = @[ @([field.pickerData[0] indexOfObject:self.user.medicalConditions]) ];
                    }
                    else {
                        field.selectedRowIndices = @[ @(0) ];
                    }
                    
                    APCTableViewRow *row = [APCTableViewRow new];
                    row.item = field;
                    row.itemType = kAPCUserInfoItemTypeMedicalCondition;
                    [rowItems addObject:row];
                }
                    
                    break;
                    
                case kAPCUserInfoItemTypeMedication:
                {
                    APCTableViewCustomPickerItem *field = [APCTableViewCustomPickerItem new];
                    field.caption = NSLocalizedString(@"Medications", @"");
                    field.pickerData = @[[APCUser medications]];
                    field.textAlignnment = NSTextAlignmentRight;
                    field.identifier = kAPCDefaultTableViewCellIdentifier;
                    
                    if (self.user.medications) {
                        field.selectedRowIndices = @[ @([field.pickerData[0] indexOfObject:self.user.medications]) ];
                    }
                    else {
                        field.selectedRowIndices = @[ @(0) ];
                    }
                    
                    APCTableViewRow *row = [APCTableViewRow new];
                    row.item = field;
                    row.itemType = kAPCUserInfoItemTypeMedication;
                    [rowItems addObject:row];
                }
                    break;
                    
                case kAPCUserInfoItemTypeHeight:
                {
                    APCTableViewCustomPickerItem *field = [APCTableViewCustomPickerItem new];
                    field.caption = NSLocalizedString(@"Height", @"");
                    field.pickerData = [APCUser heights];
                    field.textAlignnment = NSTextAlignmentRight;
                    field.identifier = kAPCDefaultTableViewCellIdentifier;
                    
                    if (self.user.height) {
                        double heightInInches = roundf([APCUser heightInInches:self.user.height]);
                        NSString *feet = [NSString stringWithFormat:@"%d'", (int)heightInInches/12];
                        NSString *inches = [NSString stringWithFormat:@"%d''", (int)heightInInches%12];
                        
                        field.selectedRowIndices = @[ @([field.pickerData[0] indexOfObject:feet]), @([field.pickerData[1] indexOfObject:inches]) ];
                    }
                    else {
                        field.selectedRowIndices = @[ @(2), @(5) ];
                    }
                    
                    APCTableViewRow *row = [APCTableViewRow new];
                    row.item = field;
                    row.itemType = kAPCUserInfoItemTypeHeight;
                    [rowItems addObject:row];
                }
                    break;
                    
                case kAPCUserInfoItemTypeWeight:
                {
                    APCTableViewTextFieldItem *field = [APCTableViewTextFieldItem new];
                    field.caption = NSLocalizedString(@"Weight", @"");
                    field.placeholder = NSLocalizedString(@"add weight (lb)", @"");
                    field.regularExpression = kAPCMedicalInfoItemWeightRegEx;
                    if (self.user.weight) {
                        field.value = [NSString stringWithFormat:@"%.0f", [APCUser weightInPounds:self.user.weight]];
                    }
                    field.keyboardType = UIKeyboardTypeDecimalPad;
                    field.textAlignnment = NSTextAlignmentRight;
                    field.identifier = kAPCTextFieldTableViewCellIdentifier;
                    
                    APCTableViewRow *row = [APCTableViewRow new];
                    row.item = field;
                    row.itemType = kAPCUserInfoItemTypeWeight;
                    [rowItems addObject:row];
                }
                    break;
                    
                case kAPCUserInfoItemTypeWakeUpTime:
                {
                    APCTableViewDatePickerItem *field = [APCTableViewDatePickerItem new];
                    field.selectionStyle = UITableViewCellSelectionStyleGray;
                    field.style = UITableViewCellStyleValue1;
                    field.caption = NSLocalizedString(@"What time do you wake up?", @"");
                    field.placeholder = NSLocalizedString(@"7:00 AM", @"");
                    field.identifier = kAPCDefaultTableViewCellIdentifier;
                    field.datePickerMode = UIDatePickerModeTime;
                    field.dateFormat = kAPCMedicalInfoItemSleepTimeFormat;
                    field.textAlignnment = NSTextAlignmentRight;
                    field.detailDiscloserStyle = YES;
                    
                    if (self.user.sleepTime) {
                        field.date = self.user.wakeUpTime;
                        field.detailText = [field.date toStringWithFormat:kAPCMedicalInfoItemSleepTimeFormat];
                    }
                    
                    APCTableViewRow *row = [APCTableViewRow new];
                    row.item = field;
                    row.itemType = kAPCUserInfoItemTypeWakeUpTime;
                    [rowItems addObject:row];
                }
                    break;
                    
                case kAPCUserInfoItemTypeSleepTime:
                {
                    APCTableViewDatePickerItem *field = [APCTableViewDatePickerItem new];
                    field.selectionStyle = UITableViewCellSelectionStyleGray;
                    field.style = UITableViewCellStyleValue1;
                    field.caption = NSLocalizedString(@"What time do you go to sleep?", @"");
                    field.placeholder = NSLocalizedString(@"9:30 PM", @"");
                    field.identifier = kAPCDefaultTableViewCellIdentifier;
                    field.datePickerMode = UIDatePickerModeTime;
                    field.dateFormat = kAPCMedicalInfoItemSleepTimeFormat;
                    field.textAlignnment = NSTextAlignmentRight;
                    field.detailDiscloserStyle = YES;
                    
                    if (self.user.wakeUpTime) {
                        field.date = self.user.sleepTime;
                        field.detailText = [field.date toStringWithFormat:kAPCMedicalInfoItemSleepTimeFormat];
                    }
                    
                    APCTableViewRow *row = [APCTableViewRow new];
                    row.item = field;
                    row.itemType = kAPCUserInfoItemTypeSleepTime;
                    [rowItems addObject:row];
                }
                    break;
                default:
                    break;
            }
        }
        APCTableViewSection *section = [APCTableViewSection new];
        section.rows = [NSArray arrayWithArray:rowItems];
        [items addObject:section];
    }
    
    /*
     Share is disabled for now.
    {
        NSMutableArray *rowItems = [NSMutableArray new];
        
        {
            APCTableViewItem *field = [APCTableViewItem new];
            field.caption = NSLocalizedString(@"Share this Study", @"");
            field.identifier = kAPCDefaultTableViewCellIdentifier;
            field.editable = YES;
            
            APCTableViewRow *row = [APCTableViewRow new];
            row.item = field;
            row.itemType = kAPCTableViewStudyItemTypeShare;
            [rowItems addObject:row];
        }
        
        APCTableViewSection *section = [APCTableViewSection new];
        section.rows = [NSArray arrayWithArray:rowItems];
        section.sectionTitle = NSLocalizedString(@"Help us Spread the Word", @"");
        [items addObject:section];
    }
    */
    return [NSArray arrayWithArray:items];
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
    
    [self.footerTitleLabel setTextColor:[UIColor appSecondaryColor3]];
    [self.footerTitleLabel setFont:[UIFont appLightFontWithSize:16.0f]];
    
    [self.editLabel setTextColor:[UIColor appSecondaryColor1]];
    [self.editLabel setFont:[UIFont appRegularFontWithSize:14.0f]];
    
    [self.editLabel setTextColor:[UIColor appSecondaryColor1]];
    [self.editLabel setFont:[UIFont appRegularFontWithSize:14.0f]];
    
    [self.diseaseLabel setTextColor:[UIColor appPrimaryColor]];
    [self.diseaseLabel setFont:[UIFont appRegularFontWithSize:16.0f]];
    
    [self.dateRangeLabel setTextColor:[UIColor appSecondaryColor3]];
    [self.dateRangeLabel setFont:[UIFont appLightFontWithSize:16.0f]];
    
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

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    APCTableViewItemType type = [self itemTypeForIndexPath:indexPath];
    
    switch (type) {
        case kAPCTableViewStudyItemTypeShare:
        {
//            APCShareViewController *shareViewController = [[UIStoryboard storyboardWithName:@"APCOnboarding" bundle:[NSBundle appleCoreBundle]] instantiateViewControllerWithIdentifier:@"APCShareViewController"];
//            shareViewController.hidesOkayButton = YES;
//            [self.navigationController pushViewController:shareViewController animated:YES];
        }
            break;
            
        default:{
            [super tableView:tableView didSelectRowAtIndexPath:indexPath];
        }
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat height;
    
    if (section == 0) {
        height = 0;
    } else {
        height = kSectionHeaderHeight;
    }
    
    return height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UITableViewHeaderFooterView *headerView;
    
    APCTableViewSection *sectionItem = self.items[section];
    
    if (sectionItem.sectionTitle.length > 0) {
        
        headerView = [[UITableViewHeaderFooterView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.frame), kSectionHeaderHeight)];
        headerView.contentView.backgroundColor = [UIColor appSecondaryColor4];
        
        UILabel *headerLabel = [[UILabel alloc] initWithFrame:headerView.bounds];
        headerLabel.font = [UIFont appLightFontWithSize:16.0f];
        headerLabel.textColor = [UIColor appSecondaryColor3];
        headerLabel.textAlignment = NSTextAlignmentCenter;
        headerLabel.text = sectionItem.sectionTitle;
        [headerView addSubview:headerLabel];
    }
    
    return headerView;
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

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Public methods

- (void)loadProfileValuesInModel
{
    self.user.firstName = self.firstNameTextField.text;
    self.user.lastName = self.lastNameTextField.text;
    
    if (self.profileImage) {
        self.user.profileImage = UIImageJPEGRepresentation(self.profileImage, 1.0);
    }
    
    for (int j=0; j<self.items.count; j++) {
        
        APCTableViewSection *section = self.items[j];
        
        for (int i = 0; i < section.rows.count; i++) {
            
            APCTableViewRow *row = section.rows[i];
            
            APCTableViewItem *item = row.item;
            APCTableViewItemType itemType = row.itemType;
            
            switch (itemType) {
                case kAPCUserInfoItemTypeMedicalCondition:
                    self.user.medicalConditions = [(APCTableViewCustomPickerItem *)item stringValue];
                    break;
                    
                case kAPCUserInfoItemTypeMedication:
                    self.user.medications = [(APCTableViewCustomPickerItem *)item stringValue];
                    break;
                    
                case kAPCUserInfoItemTypeHeight:
                {
                    double height = [APCUser heightInInchesForSelectedIndices:[(APCTableViewCustomPickerItem *)item selectedRowIndices]];
                    HKUnit *inchUnit = [HKUnit inchUnit];
                    HKQuantity *heightQuantity = [HKQuantity quantityWithUnit:inchUnit doubleValue:height];
                    
                    self.user.height = heightQuantity;
                }
                    
                    break;
                    
                case kAPCUserInfoItemTypeWeight:
                {
                    double weight = [[(APCTableViewTextFieldItem *)item value] floatValue];
                    HKUnit *poundUnit = [HKUnit poundUnit];
                    HKQuantity *weightQuantity = [HKQuantity quantityWithUnit:poundUnit doubleValue:weight];
                    
                    self.user.weight = weightQuantity;
                }
                    break;
                    
                case kAPCUserInfoItemTypeSleepTime:
                    self.user.sleepTime = [(APCTableViewDatePickerItem *)item date];
                    break;
                    
                case kAPCUserInfoItemTypeWakeUpTime:
                    self.user.wakeUpTime = [(APCTableViewDatePickerItem *)item date];
                    break;
                    
                default:
                    //#warning ASSERT_MESSAGE Require
                    NSAssert(itemType <= kAPCUserInfoItemTypeWakeUpTime, @"ASSER_MESSAGE");
                    break;
            }
        }
        
    }
    
}

- (void)setupDataFromJSONFile:(NSString *)jsonFileName
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:jsonFileName ofType:@"json"];
    NSString *JSONString = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
    
    NSError *parseError;
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:[JSONString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&parseError];
    
    if (!parseError) {
        
        self.diseaseLabel.text = jsonDictionary[@"disease_name"];
        
        NSString *fromDate = jsonDictionary[@"from_date"];
        if (fromDate.length > 0) {
            self.dateRangeLabel.text = [fromDate stringByAppendingFormat:@" - %@", jsonDictionary[@"to_date"]];
        } else {
            self.dateRangeLabel.hidden = YES;
        }
    }
}

- (void)withdraw
{
    APCSpinnerViewController *spinnerController = [[APCSpinnerViewController alloc] init];
    [self presentViewController:spinnerController animated:YES completion:nil];
    
    typeof(self) __weak weakSelf = self;
    
    [self.user withdrawStudyOnCompletion:^(NSError *error) {
        if (error) {
            APCLogError2 (error);
            [spinnerController dismissViewControllerAnimated:NO completion:^{
                UIAlertController *alert = [UIAlertController simpleAlertWithTitle:NSLocalizedString(@"Withdraw", @"") message:error.message];
                [weakSelf presentViewController:alert animated:YES completion:nil];
            }];
        } else {
            [spinnerController dismissViewControllerAnimated:NO completion:^{
                APCWithdrawCompleteViewController *viewController = [[UIStoryboard storyboardWithName:@"APCProfile" bundle:[NSBundle appleCoreBundle]] instantiateViewControllerWithIdentifier:@"APCWithdrawCompleteViewController"];
                UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
                [weakSelf.navigationController presentViewController:navController animated:YES completion:nil];
            }];
        }
    }];
}

#pragma mark - IBActions

- (IBAction)showSettings:(id)sender
{
    APCSettingsViewController *settingsViewController = [[UIStoryboard storyboardWithName:@"APCProfile" bundle:[NSBundle appleCoreBundle]] instantiateViewControllerWithIdentifier:@"APCSettingsViewController"];
    [self.navigationController pushViewController:settingsViewController animated:YES];
}

- (IBAction)signOut:(id)sender
{
    UIAlertController *alertContorller = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Sign Out", @"") message:NSLocalizedString(@"Are you sure you want to sign out?", nil) preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Sign Out", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[NSNotificationCenter defaultCenter] postNotificationName:APCUserLogOutNotification object:self];
    }];
    [alertContorller addAction:yesAction];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
       
    }];
    [alertContorller addAction:cancelAction];
    
    [self.navigationController presentViewController:alertContorller animated:YES completion:nil];
    
}

- (IBAction)leaveStudy:(id)sender
{
    UIAlertController *alertContorller = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Withdraw", @"") message:NSLocalizedString(@"Are you sure you want to withdraw from the study?\nThis action cannot be undone.", nil) preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Withdraw", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self withdraw];
    }];
    [alertContorller addAction:yesAction];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];
    [alertContorller addAction:cancelAction];
    
    [self.navigationController presentViewController:alertContorller animated:YES completion:nil];
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
        
        self.navigationItem.leftBarButtonItem.enabled = YES;
        
        [self loadProfileValuesInModel];
    } else{
        
        sender.title = NSLocalizedString(@"Done", @"Done");
        sender.style = UIBarButtonItemStyleDone;
        
        self.navigationItem.leftBarButtonItem.enabled = NO;
    }
    
    self.editing = !self.editing;
    
    self.firstNameTextField.enabled = self.isEditing;
    self.lastNameTextField.enabled = self.isEditing;
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
