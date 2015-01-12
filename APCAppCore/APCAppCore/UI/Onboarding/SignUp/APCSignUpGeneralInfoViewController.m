// 
//  APCSignUpGeneralInfoViewController.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "APCSignUpGeneralInfoViewController.h"
#import "APCPermissionButton.h"
#import "APCPermissionsManager.h"


@interface APCSignUpGeneralInfoViewController () <APCTermsAndConditionsViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, APCFormTextFieldDelegate>

@property (nonatomic, strong) APCPermissionsManager *permissionManager;
@property (nonatomic) BOOL permissionGranted;
@property (weak, nonatomic) IBOutlet APCPermissionButton *permissionButton;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextBarButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *alertLabelBottomConstraint;
@property (weak, nonatomic) IBOutlet UILabel *alertLabel;

@property (nonatomic, strong) UIImage *profileImage;

@end

@implementation APCSignUpGeneralInfoViewController

#pragma mark - View Life Cycle

- (void) viewDidLoad {
    [super viewDidLoad];
    
    [self setupNavAppearance];
    
    self.items = [self prepareContent];
    
    self.permissionButton.unconfirmedTitle = NSLocalizedString(@"Enter the study and contribute your data", @"");
    self.permissionButton.confirmedTitle = NSLocalizedString(@"Enter the study and contribute your data", @"");
    self.permissionButton.attributed = NO;
    self.permissionButton.alignment = kAPCPermissionButtonAlignmentLeft;
    
    self.permissionManager = [[APCPermissionsManager alloc] init];
    
    __weak typeof(self) weakSelf = self;
    [self.permissionManager requestForPermissionForType:kSignUpPermissionsTypeHealthKit withCompletion:^(BOOL granted, NSError *error) {
        if (granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.permissionGranted = YES;
                weakSelf.items = [self prepareContent];
                [weakSelf.tableView reloadData];
            });
        }
    }];
    
    //Set Default Values
    [self.profileImageButton setImage:[UIImage imageNamed:@"profilePlaceholder"] forState:UIControlStateNormal];
    self.nameTextField.text = self.user.consentSignatureName;
    if (self.nameTextField.text.length > 0){
        self.nameTextField.valid = YES;
    }
    
    self.nameTextField.validationDelegate = self;
    [self.nameTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    self.emailTextField.validationDelegate = self;
    [self.emailTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
  APCLogViewControllerAppeared();
}

- (void)setupAppearance
{
    [super setupAppearance];
    
    self.alertLabel.alpha = 0;
    [self.alertLabel setFont:[UIFont appRegularFontWithSize:15.0f]];
}

- (void)setupNavAppearance
{
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 0, 44, 44);
    [backButton setImage:[[UIImage imageNamed:@"back_button"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    backButton.tintColor = [UIColor appPrimaryColor];
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [self.navigationItem setLeftBarButtonItem:backBarButton];
    
    self.nextBarButton.enabled = NO;
}

- (NSArray *)prepareContent {
    
    NSDictionary *initialOptions = ((APCAppDelegate *)[UIApplication sharedApplication].delegate).initializationOptions;
    NSArray *profileElementsList = initialOptions[kAppProfileElementsListKey];
    
    NSMutableArray *items = [NSMutableArray new];
    NSMutableArray *rowItems = [NSMutableArray new];

    {
        APCTableViewTextFieldItem *field = [APCTableViewTextFieldItem new];
        field.caption = NSLocalizedString(@"Password", @"");
        field.placeholder = NSLocalizedString(@"add password", @"");
        field.keyboardType = UIKeyboardTypeASCIICapable;
        field.returnKeyType = UIReturnKeyNext;
        field.identifier = kAPCTextFieldTableViewCellIdentifier;
        field.style = UITableViewCellStyleValue1;
        
        APCTableViewRow *row = [APCTableViewRow new];
        row.item = field;
        row.itemType = kAPCUserInfoItemTypePassword;
        [rowItems addObject:row];
    }
    
    
    for (NSNumber *type in profileElementsList) {
        
        APCUserInfoItemType itemType = type.integerValue;
        switch (itemType) {
            case kAPCUserInfoItemTypeDateOfBirth:
            {
                APCTableViewDatePickerItem *field = [APCTableViewDatePickerItem new];
                field.caption = NSLocalizedString(@"Birthdate", @"");
                field.placeholder = NSLocalizedString(@"add birthdate", @"");
                field.datePickerMode = UIDatePickerModeDate;
                field.style = UITableViewCellStyleValue1;
                field.selectionStyle = UITableViewCellSelectionStyleGray;
                field.identifier = kAPCDefaultTableViewCellIdentifier;
                
                NSCalendar * gregorian = [[NSCalendar alloc] initWithCalendarIdentifier: NSCalendarIdentifierGregorian];
                
                NSDate * currentDate = [NSDate date];
                NSDateComponents * comps = [[NSDateComponents alloc] init];
                [comps setYear: -18];
                NSDate * maxDate = [gregorian dateByAddingComponents: comps toDate: currentDate options: 0];
                field.maximumDate = maxDate;
                
                if (self.user.birthDate) {
                    field.date = self.user.birthDate;
                } else{
                    field.date = maxDate;
                }
                
                field.detailText = [field.date toStringWithFormat:field.dateFormat];
                APCTableViewRow *row = [APCTableViewRow new];
                row.item = field;
                row.itemType = kAPCUserInfoItemTypeDateOfBirth;
                [rowItems addObject:row];
            }
                break;
            case kAPCUserInfoItemTypeBiologicalSex:
            {
                APCTableViewSegmentItem *field = [APCTableViewSegmentItem new];
                field.style = UITableViewCellStyleValue1;
                field.segments = [APCUser sexTypesInStringValue];
                field.identifier = kAPCSegmentedTableViewCellIdentifier;
                
                if (self.permissionGranted && self.user.biologicalSex) {
                    field.selectedIndex = [APCUser stringIndexFromSexType:self.user.biologicalSex];
                    field.editable = NO;
                }
                
                APCTableViewRow *row = [APCTableViewRow new];
                row.item = field;
                row.itemType = kAPCUserInfoItemTypeBiologicalSex;
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
    
    return [NSArray arrayWithArray:items];
}

- (APCOnboarding *)onboarding
{
    return ((APCAppDelegate *)[UIApplication sharedApplication].delegate).onboarding;
}

#pragma mark - UITextFieldDelegate methods

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [UIView animateWithDuration:0.3 animations:^{
        self.alertLabel.alpha = 0;
    }];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [super textFieldShouldReturn:textField];
    
    [self.nextBarButton setEnabled:[self isContentValid:nil]];
    
    return YES;
}

- (void)textFieldDidChange:(UITextField *)textField
{
    [UIView animateWithDuration:0.3 animations:^{
        self.alertLabel.alpha = 0;
    }];
    
    [self validateFieldForTextField:textField];
    
    [self.nextBarButton setEnabled:[self isContentValid:nil]];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.nextBarButton.enabled = [self isContentValid:nil];
    
    [self validateFieldForTextField:textField];
}

#pragma mark - APCFormTextFieldDelegate methods

- (void)formTextFieldDidTapValidButton:(APCFormTextField *)textField
{
    [self validateFieldForTextField:textField];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.alertLabel.alpha = 1.0;
    } completion:nil];
}

- (void)validateFieldForTextField:(UITextField *)textField
{
    NSString *errorMessage = @"";
    
    if (textField == self.emailTextField) {
        
        BOOL valid = [self isFieldValid:nil forType:kAPCUserInfoItemTypeEmail errorMessage:&errorMessage];
        self.emailTextField.valid = valid;
        
    } else if (textField == self.nameTextField) {
        BOOL valid = [self isFieldValid:nil forType:kAPCUserInfoItemTypeName errorMessage:&errorMessage];
        self.nameTextField.valid = valid;
    }
    
    self.alertLabel.text = errorMessage;
}

#pragma mark - APCPickerTableViewCellDelegate methods

- (void)pickerTableViewCell:(APCPickerTableViewCell *)cell datePickerValueChanged:(NSDate *)date
{
    [super pickerTableViewCell:cell datePickerValueChanged:date];
}

- (void)pickerTableViewCell:(APCPickerTableViewCell *)cell pickerViewDidSelectIndices:(NSArray *)selectedIndices
{
    [super pickerTableViewCell:cell pickerViewDidSelectIndices:selectedIndices];
}

#pragma mark - APCTextFieldTableViewCellDelegate methods

- (void)textFieldTableViewCellDidBeginEditing:(APCTextFieldTableViewCell *)cell
{
    [UIView animateWithDuration:0.3 animations:^{
        self.alertLabel.alpha = 0;
    }];
}

- (void)textFieldTableViewCellDidEndEditing:(APCTextFieldTableViewCell *)cell
{
    [super textFieldTableViewCellDidEndEditing:cell];
    
    self.nextBarButton.enabled = [self isContentValid:nil];
    
    [self validateFieldForCell:cell];
}

- (void)textFieldTableViewCellDidChangeText:(APCTextFieldTableViewCell *)cell
{
    [super textFieldTableViewCellDidChangeText:cell];
    
    self.nextBarButton.enabled = [self isContentValid:nil];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.alertLabel.alpha = 0;
    }];
    
    [self validateFieldForCell:cell];
    
    [self.nextBarButton setEnabled:[self isContentValid:nil]];
}

- (void)textFieldTableViewCellDidReturn:(APCTextFieldTableViewCell *)cell
{
    [super textFieldTableViewCellDidReturn:cell];
    
    self.nextBarButton.enabled = [self isContentValid:nil];
}

- (void)textFieldTableViewCellDidTapValidationButton:(APCTextFieldTableViewCell *)cell
{
    [self validateFieldForCell:cell];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.alertLabel.alpha = 1.0;
    } completion:nil];
}

- (void)validateFieldForCell:(APCTextFieldTableViewCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    APCTableViewTextFieldItem *item = (APCTableViewTextFieldItem *)[self itemForIndexPath:indexPath];
    APCTableViewItemType itemType = [self itemTypeForIndexPath:indexPath];
    
    NSString *errorMessage = @"";
    
    BOOL valid = [self isFieldValid:item forType:itemType errorMessage:&errorMessage];
    
    if ([cell.textField isKindOfClass:[APCFormTextField class]]) {
        ((APCFormTextField *)cell.textField).valid = valid;
    }
    
    self.alertLabel.text = errorMessage;
}

#pragma mark - APCSegmentedTableViewCellDelegate methods

- (void)segmentedTableViewCell:(APCSegmentedTableViewCell *)cell didSelectSegmentAtIndex:(NSInteger)index
{
    [super segmentedTableViewCell:cell didSelectSegmentAtIndex:index];
}

#pragma mark - Private Methods

- (BOOL) isContentValid:(NSString **)errorMessage {
    
    BOOL isContentValid = [super isContentValid:errorMessage];
    
    if (isContentValid) {
        
        for (int j=0; j<self.items.count; j++) {
            
            APCTableViewSection *section = self.items[j];
            
            for (int i = 0; i < section.rows.count; i++) {
                
                APCTableViewRow *row = section.rows[i];
                
                APCTableViewItem *item = row.item;
                APCTableViewItemType itemType = row.itemType;
                
                switch (itemType) {
                        
                    case kAPCUserInfoItemTypeEmail:
                    {
                        isContentValid = [[(APCTableViewTextFieldItem *)item value] isValidForRegex:kAPCGeneralInfoItemEmailRegEx];
                        
                        if (errorMessage) {
                            *errorMessage = NSLocalizedString(@"Please enter a valid email address.", @"");
                        }
                    }
                        break;
                        
                    case kAPCUserInfoItemTypePassword:
                    {
                        if ([[(APCTableViewTextFieldItem *)item value] length] == 0) {
                            isContentValid = NO;
                            
                            if (errorMessage) {
                                *errorMessage = NSLocalizedString(@"Please enter a Password.", @"");
                            }
                        }
                        else if ([[(APCTableViewTextFieldItem *)item value] length] < kAPCPasswordMinimumLength) {
                            isContentValid = NO;
                            
                            if (errorMessage) {
                                *errorMessage = [NSString stringWithFormat:NSLocalizedString(@"Password should be at least %d characters", ), kAPCPasswordMinimumLength];
                            }
                        }
                    }
                        break;
                        
                    default:
                        NSAssert(itemType <= kAPCUserInfoItemTypeWakeUpTime, @"ASSER_MESSAGE");
                        break;
                }
                
                // If any of the content is not valid the break the for loop
                // We doing this 'break' here because we cannot break a for loop inside switch-statements (switch already have break statement)
                if (!isContentValid) {
                    break;
                }
            }
        }
        
    }
    
    //Commented as Terms & Conditions is disabled for now.
    
//    if (isContentValid) {
//        isContentValid = self.permissionButton.isSelected;
//    }
    
    return isContentValid;
}

- (BOOL)isFieldValid:(APCTableViewTextFieldItem *)item forType:(APCTableViewItemType)type errorMessage:(NSString **)errorMessage
{
    BOOL fieldValid = NO;
    
    if (type == kAPCUserInfoItemTypeEmail) {
        
        if (self.emailTextField.text.length > 0) {
            fieldValid = [self.emailTextField.text isValidForRegex:kAPCGeneralInfoItemEmailRegEx];
            
            if (errorMessage && !fieldValid) {
                *errorMessage = NSLocalizedString(@"Please enter a valid email address.", @"");
            }
        } else {
            if (errorMessage && !fieldValid) {
                *errorMessage = NSLocalizedString(@"Email address cannot be left empty.", @"");
            }
        }
        
    } else if (type == kAPCUserInfoItemTypeName) {
        
        if (self.nameTextField.text.length == 0) {
            if (errorMessage && !fieldValid) {
                *errorMessage = NSLocalizedString(@"Name cannot be left empty.", @"");
            }
        } else {
            fieldValid = YES;
        }
    } else {
        switch (type) {
            case kAPCUserInfoItemTypePassword:
                if ([[item value] length] == 0) {
                    
                    if (errorMessage) {
                        *errorMessage = NSLocalizedString(@"Please enter a Password.", @"");
                    }
                } else if ([[item value] length] < kAPCPasswordMinimumLength) {
                    
                    if (errorMessage) {
                        *errorMessage = [NSString stringWithFormat:NSLocalizedString(@"Password should be at least %d characters", ), kAPCPasswordMinimumLength];
                    }
                } else {
                    fieldValid = YES;
                }
                break;
                
            default:
                break;
        }
    }
    
    return fieldValid;
}

- (void) loadProfileValuesInModel {
    
    if (self.tableView.tableHeaderView) {
        self.user.name = self.nameTextField.text;
        self.user.email = self.emailTextField.text;
        
        if (self.profileImage) {
            self.user.profileImage = UIImageJPEGRepresentation(self.profileImage, 1.0);
        }
    }
    
    
    for (int j=0; j<self.items.count; j++) {
        
        APCTableViewSection *section = self.items[j];
        
        for (int i = 0; i < section.rows.count; i++) {
            
            APCTableViewRow *row = section.rows[i];
            
            APCTableViewItem *item = row.item;
            APCTableViewItemType itemType = row.itemType;
            
            switch (itemType) {
                    
                case kAPCUserInfoItemTypePassword:
                    self.user.password = [(APCTableViewTextFieldItem *)item value];
                    break;
                    
                case kAPCUserInfoItemTypeBiologicalSex:{
                    self.user.biologicalSex = [APCUser sexTypeForIndex:((APCTableViewSegmentItem *)item).selectedIndex];
                }
                    break;
                case kAPCUserInfoItemTypeDateOfBirth:
                    //self.user.birthDate = [(APCTableViewDatePickerItem *)item date];
                default:
                {
                    //Do nothing for some types as they are readonly attributes
                }
                    break;
            }
        }
    }
    
}

- (void) validateContent {
    [self.tableView endEditing:YES];
    
    NSString *message;
    if ([self isContentValid:&message]) {
        [self loadProfileValuesInModel];
        [self next];
    }
    else {
        UIAlertController *alert = [UIAlertController simpleAlertWithTitle:NSLocalizedString(@"General Information", @"") message:message];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

#pragma mark - APCTermsAndConditionsViewControllerDelegate methods

- (void)termsAndConditionsViewControllerDidAgree
{
    [self.permissionButton setSelected:YES];
    
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        [self.nextBarButton setEnabled:[self isContentValid:nil]];
    }];
}

- (void)termsAndConditionsViewControllerDidCancel
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
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

#pragma mark - IBActions

- (IBAction)termsAndConditions:(UIButton *)sender
{
    APCTermsAndConditionsViewController *termsViewController =  [[UIStoryboard storyboardWithName:@"APCOnboarding" bundle:[NSBundle appleCoreBundle]] instantiateViewControllerWithIdentifier:@"APCTermsAndConditionsViewController"];
    termsViewController.delegate = self;
    [self.navigationController presentViewController:termsViewController animated:YES completion:nil];
}

- (void) secretButton
{
    self.nameTextField.text = @"John Appleseed";
    
    NSUInteger randomInteger = arc4random();
    self.emailTextField.text = [NSString stringWithFormat:@"dhanush.balachandran+%@@ymedialabs.com", @(randomInteger)];
    
    for (int j=0; j<self.items.count; j++) {
        
        APCTableViewSection *section = self.items[j];
        
        for (int i = 0; i < section.rows.count; i++) {
            
            APCTableViewRow *row = section.rows[i];
            
            APCTableViewTextFieldItem *item = (APCTableViewTextFieldItem *)row.item;
            APCTableViewItemType itemType = row.itemType;
            
            switch (itemType) {
                case kAPCUserInfoItemTypePassword:
                    item.value = @"Password123";
                    break;
                    
                default:
                {
                    //Do nothing for some types
                }
                    break;
            }
        }
    }
    
    [self.tableView reloadData];
    
    [self.permissionButton setSelected:YES];
    
    [self.nextBarButton setEnabled:[self isContentValid:nil]];
}

- (IBAction)next
{
    
    if ([self isContentValid:nil]) {
        
        [self loadProfileValuesInModel];
        
        [self sendCredentials];
        
    }
}

-(void) sendCredentials{
    APCSpinnerViewController *spinnerController = [[APCSpinnerViewController alloc] init];
    [self presentViewController:spinnerController animated:YES completion:nil];
    
    typeof(self) __weak weakSelf = self;
    [self.user signUpOnCompletion:^(NSError *error) {
        if (error) {
            
            APCLogError2 (error);
            [spinnerController dismissViewControllerAnimated:NO completion:^{
                
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Sign Up", @"")
                                                                   message:error.message
                                                                  delegate:self
                                                         cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                                         otherButtonTitles:NSLocalizedString(@"Try Again", nil), nil];
                [alertView show];
                
            }];
        }
        else
        {
            [spinnerController dismissViewControllerAnimated:NO completion:^{
                
                UIViewController *viewController = [[self onboarding] nextScene];
                [weakSelf.navigationController pushViewController:viewController animated:YES];
            }];
        }
    }];
}


- (IBAction)cancel:(id)sender
{
    
}

- (IBAction)changeProfileImage:(id)sender
{
    __weak typeof(self) weakSelf = self;
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Take Photo", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        [self.permissionManager requestForPermissionForType:kSignUpPermissionsTypeCamera withCompletion:^(BOOL granted, NSError *error) {
            if (granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf openCamera];
                });
            }else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf presentSettingsAlert:error];
                });
            }
        }];
    }];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [alertController addAction:cameraAction];
    }
    
    UIAlertAction *libraryAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Choose from Library", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self.permissionManager requestForPermissionForType:kSignUpPermissionsTypePhotoLibrary withCompletion:^(BOOL granted, NSError *error) {
            if (granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf openPhotoLibrary];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf presentSettingsAlert:error];
                });
            }
        }];
    }];
    [alertController addAction:libraryAction];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)openCamera
{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.editing = YES;
    imagePickerController.allowsEditing = YES;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePickerController.delegate = self;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (void)openPhotoLibrary
{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.editing = YES;
    imagePickerController.allowsEditing = YES;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.delegate = self;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (void)presentSettingsAlert:(NSError *)error
{
    UIAlertController *alertContorller = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Permissions Denied", @"") message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *dismiss = [UIAlertAction actionWithTitle:NSLocalizedString(@"Dismiss", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
    }];
    [alertContorller addAction:dismiss];
    UIAlertAction *settings = [UIAlertAction actionWithTitle:NSLocalizedString(@"Settings", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }];
    [alertContorller addAction:settings];
    
    [self.navigationController presentViewController:alertContorller animated:YES completion:nil];
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
    [[self onboarding] popScene];
}

#pragma mark AlertView delegate

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 0) {
        NSLog(@"canceled");
    }else{
        //try again
        NSLog(@"Trying again");
        [self sendCredentials];
    }
    
}



@end
