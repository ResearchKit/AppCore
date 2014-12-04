// 
//  APCSignUpGeneralInfoViewController.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "APCSignUpGeneralInfoViewController.h"
#import "APCPermissionButton.h"
#import "APCPermissionsManager.h"

@interface APCSignUpGeneralInfoViewController () <APCTermsAndConditionsViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) APCPermissionsManager *permissionManager;
@property (nonatomic) BOOL permissionGranted;
@property (weak, nonatomic) IBOutlet APCPermissionButton *permissionButton;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextBarButton;

@property (nonatomic, strong) UIImage *profileImage;

@end

@implementation APCSignUpGeneralInfoViewController

#pragma mark - View Life Cycle

- (void) viewDidLoad {
    [super viewDidLoad];
    
    [self setupNavigationItems];
    self.items = [self prepareContent];
    
    self.permissionButton.unconfirmedTitle = NSLocalizedString(@"Enter the study and contribute your data", @"");
    self.permissionButton.confirmedTitle = NSLocalizedString(@"Enter the study and contribute your data", @"");
    self.permissionButton.attributed = NO;
    self.permissionButton.alignment = kAPCPermissionButtonAlignmentLeft;
    
    self.permissionManager = [[APCPermissionsManager alloc] init];
    
    self.permissionGranted = [self.permissionManager isPermissionsGrantedForType:kSignUpPermissionsTypeHealthKit];
    
    if (!self.permissionGranted) {
        [self.permissionManager requestForPermissionForType:kSignUpPermissionsTypeHealthKit withCompletion:^(BOOL granted, NSError *error) {
            if (granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.permissionGranted = YES;
                    self.items = [self prepareContent];
                    [self.tableView reloadData];
                });
            }
        }];
    } else{
        self.items = [self prepareContent];
    }
    
    [self.profileImageButton setImage:[UIImage imageNamed:@"profilePlaceholder"] forState:UIControlStateNormal];
}

- (void)setupAppearance
{
    [super setupAppearance];
}

- (void)setupNavigationItems
{
    self.nextBarButton.enabled = NO;
    
    //#if DEVELOPMENT
    UIBarButtonItem *hiddenButton = [[UIBarButtonItem alloc] initWithTitle:@"   " style:UIBarButtonItemStylePlain target:self action:@selector(secretButton)];
    
    [self.navigationItem setRightBarButtonItems:@[self.nextBarButton, hiddenButton]];
    //#endif
}

- (NSArray *)prepareContent {
    
    NSMutableArray *items = [NSMutableArray new];
    NSMutableArray *rowItems = [NSMutableArray new];
    
    {
        APCTableViewTextFieldItem *field = [APCTableViewTextFieldItem new];
        field.caption = NSLocalizedString(@"Email", @"");
        field.placeholder = NSLocalizedString(@"add email", @"");
        field.keyboardType = UIKeyboardTypeEmailAddress;
        field.returnKeyType = UIReturnKeyNext;
        field.clearButtonMode = UITextFieldViewModeWhileEditing;
        field.identifier = kAPCTextFieldTableViewCellIdentifier;
        field.style = UITableViewCellStyleValue1;
        
        APCTableViewRow *row = [APCTableViewRow new];
        row.item = field;
        row.itemType = kAPCUserInfoItemTypeEmail;
        [rowItems addObject:row];
    }
    
    {
        APCTableViewTextFieldItem *field = [APCTableViewTextFieldItem new];
        field.caption = NSLocalizedString(@"Password", @"");
        field.placeholder = NSLocalizedString(@"add password", @"");
        field.secure = YES;
        field.keyboardType = UIKeyboardTypeDefault;
        field.returnKeyType = UIReturnKeyNext;
        field.clearButtonMode = UITextFieldViewModeWhileEditing;
        field.identifier = kAPCTextFieldTableViewCellIdentifier;
        field.style = UITableViewCellStyleValue1;
        
        APCTableViewRow *row = [APCTableViewRow new];
        row.item = field;
        row.itemType = kAPCUserInfoItemTypePassword;
        [rowItems addObject:row];
    }
    
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
        
        if (self.permissionGranted && self.user.birthDate) {
            field.date = self.user.birthDate;
            field.detailText = [field.date toStringWithFormat:field.dateFormat];
            field.editable = NO;
        } else{
            field.date = maxDate;
        }
        
        APCTableViewRow *row = [APCTableViewRow new];
        row.item = field;
        row.itemType = kAPCUserInfoItemTypeDateOfBirth;
        [rowItems addObject:row];
    }
    
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

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [super textFieldShouldReturn:textField];
    
    [self.nextBarButton setEnabled:[self isContentValid:nil]];
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return [super textField:textField shouldChangeCharactersInRange:range replacementString:string];
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self.nextBarButton setEnabled:[self isContentValid:nil]];
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

- (void)textFieldTableViewCellDidEndEditing:(APCTextFieldTableViewCell *)cell
{
    [super textFieldTableViewCellDidEndEditing:cell];
    
    self.nextBarButton.enabled = [self isContentValid:nil];
}

- (void)textFieldTableViewCell:(APCTextFieldTableViewCell *)cell shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    [super textFieldTableViewCell:cell shouldChangeCharactersInRange:range replacementString:string];
    
    self.nextBarButton.enabled = [self isContentValid:nil];
}

- (void)textFieldTableViewCellDidReturn:(APCTextFieldTableViewCell *)cell
{
    [super textFieldTableViewCellDidReturn:cell];
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    APCTableViewTextFieldItem *item = (APCTableViewTextFieldItem *)[self itemForIndexPath:indexPath];
    APCTableViewItemType itemType = [self itemTypeForIndexPath:indexPath];
    
    if (itemType == kAPCUserInfoItemTypePassword) {
        if (item.value.length == 0) {
            UIAlertController *alert = [UIAlertController simpleAlertWithTitle:NSLocalizedString(@"General Information", @"") message:NSLocalizedString(@"Please give a valid Password", nil)];
            [self presentViewController:alert animated:YES completion:nil];
        }
        else if (item.value.length < kAPCPasswordMinimumLength) {
            UIAlertController *alert = [UIAlertController simpleAlertWithTitle:NSLocalizedString(@"General Information", @"") message:[NSString stringWithFormat:NSLocalizedString(@"Password should be at least %d characters", ), kAPCPasswordMinimumLength]];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
    else if (itemType == kAPCUserInfoItemTypeEmail) {
        if (![item.value isValidForRegex:kAPCGeneralInfoItemEmailRegEx]) {
            UIAlertController *alert = [UIAlertController simpleAlertWithTitle:NSLocalizedString(@"General Information", @"") message:@"Please give a valid email address"];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
    
    self.nextBarButton.enabled = [self isContentValid:nil];
    
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
                        //#warning ASSERT_MESSAGE Require
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

- (void) loadProfileValuesInModel {
    
    if (self.tableView.tableHeaderView) {
        self.user.firstName = self.firstNameTextField.text;
        self.user.lastName = self.lastNameTextField.text;
        
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
                    
                case kAPCUserInfoItemTypeEmail:
                    self.user.email = [(APCTableViewTextFieldItem *)item value];
                    break;
                    
                case kAPCUserInfoItemTypeBiologicalSex:{
                    self.user.biologicalSex = [APCUser sexTypeForIndex:((APCTableViewSegmentItem *)item).selectedIndex];
                }
                    break;
                    
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
    self.firstNameTextField.text = @"John";
    self.lastNameTextField.text = @"Appleseed";
    
    NSUInteger randomInteger = arc4random();
    
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
                    
                case kAPCUserInfoItemTypeEmail:
                    item.value = [NSString stringWithFormat:@"dhanush.balachandran+%@@ymedialabs.com", @(randomInteger)];
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
    NSString *error;
    
    if ([self isContentValid:&error]) {
        
        [self loadProfileValuesInModel];
        
        UIViewController *viewController = [[self onboarding] nextScene];
        [self.navigationController pushViewController:viewController animated:YES];
        
    } else{
        UIAlertController *alert = [UIAlertController simpleAlertWithTitle:NSLocalizedString(@"General Information", @"") message:error];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
}

- (IBAction)cancel:(id)sender
{
    
}

- (IBAction)changeProfileImage:(id)sender
{
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

@end
