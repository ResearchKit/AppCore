// 
//  APCSignUpGeneralInfoViewController.m 
//  APCAppCore 
// 
// Copyright (c) 2015, Apple Inc. All rights reserved. 
// 
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
// 
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
// 
// 2.  Redistributions in binary form must reproduce the above copyright notice, 
// this list of conditions and the following disclaimer in the documentation and/or 
// other materials provided with the distribution. 
// 
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors 
// may be used to endorse or promote products derived from this software without 
// specific prior written permission. No license is granted to the trademarks of 
// the copyright holders even if such marks are included in this software. 
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE 
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
// 
 
#import "APCSignUpGeneralInfoViewController.h"
#import "APCTermsAndConditionsViewController.h"
#import "APCPermissionButton.h"
#import "APCPermissionsManager.h"
#import "APCOnboardingManager.h"
#import "APCLog.h"

#import "APCAppDelegate.h"

#import "UIColor+APCAppearance.h"
#import "NSDate+Helper.h"
#import "NSString+Helper.h"
#import "UIFont+APCAppearance.h"
#import "UIAlertController+Helper.h"
#import "NSBundle+Helper.h"
#import "APCSpinnerViewController.h"
#import "APCUser+Bridge.h"
#import "NSError+APCAdditions.h"

static NSString *kInternetNotAvailableErrorMessage1 = @"Internet Not Connected";
static NSString *kInternetNotAvailableErrorMessage2 = @"BackendServer Not Reachable";
static NSString * const kInternalMaxParticipantsMessage = @"has reached the limit of allowed participants.";

static CGFloat kHeaderHeight = 157.0f;

@interface APCSignUpGeneralInfoViewController () <APCTermsAndConditionsViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, APCFormTextFieldDelegate>

@property (nonatomic, strong) APCPermissionsManager *permissionsManager;
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
    
    self.permissionsManager = [(id<APCOnboardingManagerProvider>)[UIApplication sharedApplication].delegate onboardingManager].permissionsManager;
    
    __weak typeof(self) weakSelf = self;
    [self.permissionsManager requestForPermissionForType:kAPCSignUpPermissionsTypeHealthKit withCompletion:^(BOOL granted, NSError * __unused error) {
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UIEdgeInsets inset = self.tableView.contentInset;
    self.tableView.contentInset = inset;
    
    if (self.headerView && (CGRectGetHeight(self.headerView.frame) != kHeaderHeight)) {
        CGRect headerRect = self.headerView.frame;
        headerRect.size.height = kHeaderHeight;
        self.headerView.frame = headerRect;
        
        self.tableView.tableHeaderView = self.tableView.tableHeaderView;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self restoreSceneData];
    
  APCLogViewControllerAppeared();
}

- (void)setupAppearance
{
    [super setupAppearance];
    
    self.footerLabel.font = [UIFont appRegularFontWithSize:16.0f];
    self.footerLabel.text = NSLocalizedString(@"Sage Bionetworks, a non-profit biomedical research institute, is helping to collect data for this study and distribute it to the study investigators and other researchers. Please provide a unique email address and password to create a secure account.", @"");
    self.footerLabel.textColor = [UIColor appSecondaryColor2];
    
}

- (void)setupNavAppearance
{
    UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                   target:self
                                                                                   action:@selector(back)];
    [self.navigationItem setLeftBarButtonItem:backBarButton];
    
    self.nextBarButton.enabled = NO;
}

- (void)saveSceneData
{
    NSDictionary *generalInfoSceneData = @{
                                           @"email": self.emailTextField.text ?:[NSNull null],
                                           @"photo": self.profileImage ?:[NSNull null]
                                           };
    
    [self.onboarding.sceneData setObject:generalInfoSceneData forKey:self.onboarding.currentStep.identifier];
}

- (void)restoreSceneData
{
    // check if there is data for the scene
    NSDictionary *sceneData = [self.onboarding.sceneData valueForKey:self.onboarding.currentStep.identifier];
    
    if (sceneData) {
        if (sceneData[@"email"] != [NSNull null]) {
            self.emailTextField.text = sceneData[@"email"];
        }
        
        if (sceneData[@"photo"] != [NSNull null]) {
            self.profileImage = sceneData[@"photo"];
            self.profileImageButton.imageView.image = self.profileImage;
        }
    }
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
                
                NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier: NSCalendarIdentifierGregorian];
                NSDate *currentDate = [[NSDate date] startOfDay];
                NSDateComponents * comps = [[NSDateComponents alloc] init];
                [comps setYear: -18];
                NSDate *maxDate = [gregorian dateByAddingComponents: comps toDate: currentDate options: 0];
                field.maximumDate = maxDate;
                
                if (self.user.birthDate) {
                    field.date = self.user.birthDate;
                } else{
                    [comps setYear:-30];
                    NSDate *defaultDate = [gregorian dateByAddingComponents: comps toDate: currentDate options: 0];
                    field.date = defaultDate;
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
    return [(id<APCOnboardingManagerProvider>)[UIApplication sharedApplication].delegate onboardingManager].onboarding;
}

#pragma mark - UITextFieldDelegate methods

- (void)textFieldDidBeginEditing:(UITextField *) __unused textField
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

- (void)textFieldTableViewCellDidBeginEditing:(APCTextFieldTableViewCell *) __unused cell
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
        
        for (NSUInteger j=0; j<self.items.count; j++) {
            
            APCTableViewSection *section = self.items[j];
            
            for (NSUInteger i = 0; i < section.rows.count; i++) {
                
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
    
    
    for (NSUInteger j=0; j<self.items.count; j++) {
        
        APCTableViewSection *section = self.items[j];
        
        for (NSUInteger i = 0; i < section.rows.count; i++) {
            
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
                    self.user.birthDate = [(APCTableViewDatePickerItem *)item date];
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
    
    picker.delegate = nil;
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    picker.delegate = nil;
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - IBActions

- (IBAction) termsAndConditions: (UIButton *) __unused sender
{
    APCTermsAndConditionsViewController *termsViewController =  [[UIStoryboard storyboardWithName:@"APCOnboarding" bundle:[NSBundle appleCoreBundle]] instantiateViewControllerWithIdentifier:@"APCTermsAndConditionsViewController"];
    termsViewController.delegate = self;
    [self.navigationController presentViewController:termsViewController animated:YES completion:nil];
}

- (void) secretButton
{
    // Disable the secret button to do nothing.
    return;
}

- (IBAction)next
{
    NSString *errorMessage = @"";
    if ([self isContentValid:&errorMessage]) {
        
        [self saveSceneData];
        
        [self loadProfileValuesInModel];
        
        APCSpinnerViewController *spinnerController = [[APCSpinnerViewController alloc] init];
        [self presentViewController:spinnerController animated:YES completion:nil];
        
        typeof(self) __weak weakSelf = self;
        [self.user signUpOnCompletion:^(NSError *error) {
            if (error) {
                
                APCLogError2 (error);
            
                if ([error.message isEqualToString:kInternetNotAvailableErrorMessage1] || [error.message isEqualToString:kInternetNotAvailableErrorMessage2] || [error.message rangeOfString:kInternalMaxParticipantsMessage].location != NSNotFound) {
                    [spinnerController dismissViewControllerAnimated:NO completion:^{
                    
                        UIAlertController *alertView = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Sign Up", @"")
                                                                                            message:error.message
                                                                                     preferredStyle:UIAlertControllerStyleAlert];

                        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                              handler:^(UIAlertAction * __unused action) {}];
                        
                        [alertView addAction:defaultAction];
                        [self presentViewController:alertView animated:YES completion:nil];
                    }];
                } else {
                    [spinnerController dismissViewControllerAnimated:NO completion:^{
                        
                        UIAlertController *alertView = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Sign Up", @"")
                                                                                           message:error.message
                                                                                    preferredStyle:UIAlertControllerStyleAlert];
                        
                        UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Change Details", @"") style:UIAlertActionStyleDefault
                                                                              handler:^(UIAlertAction * __unused action) {}];
                        
                        UIAlertAction* changeAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Send Again", nil) style:UIAlertActionStyleDefault
                                                                             handler:^(UIAlertAction * __unused action) {[self next];}];
                        
                        
                        [alertView addAction:okAction];
                        [alertView addAction:changeAction];
                        [self presentViewController:alertView animated:YES completion:nil];
                        
                    }];
                }
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
}

- (IBAction)cancel:(id) __unused sender
{
    
}

- (IBAction)changeProfileImage:(id) __unused sender
{
    [UIView animateWithDuration:0.3 animations:^{
        self.alertLabel.alpha = 0;
    }];
    
    __weak typeof(self) weakSelf = self;
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Take Photo", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * __unused action) {
        
        [self.permissionsManager requestForPermissionForType:kAPCSignUpPermissionsTypeCamera withCompletion:^(BOOL granted, NSError *error) {
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
    
    UIAlertAction *libraryAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Choose from Library", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * __unused action) {
        [self.permissionsManager requestForPermissionForType:kAPCSignUpPermissionsTypePhotoLibrary withCompletion:^(BOOL granted, NSError *error) {
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
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * __unused action) {
        
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
    UIAlertAction *dismiss = [UIAlertAction actionWithTitle:NSLocalizedString(@"Dismiss", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * __unused action) {
        
    }];
    [alertContorller addAction:dismiss];
    UIAlertAction *settings = [UIAlertAction actionWithTitle:NSLocalizedString(@"Settings", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction * __unused action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }];
    [alertContorller addAction:settings];
    
    [self.navigationController presentViewController:alertContorller animated:YES completion:nil];
}

- (void)back
{
    [self saveSceneData];
    [self.navigationController popViewControllerAnimated:YES];
    [[self onboarding] popScene];
}

@end
