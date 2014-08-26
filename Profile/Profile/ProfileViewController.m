//
//  ViewController.m
//  Profile
//
//  Created by Karthik Keyan on 8/22/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "Profile.h"
#import "ProfileCell.h"
#import "ProfileViewController.h"

// Cell Identifiers
static NSString * const kProfileTableViewCellImageTextIdentifier    = @"ProfileImageTextCell";
static NSString * const kProfileTableViewCellTextIdentifier         = @"ProfileTextCell";
static NSString * const kProfileTableViewCellDateIdentifier         = @"ProfileDateCell";
static NSString * const kProfileTableViewCellTitleValueIdentifier   = @"ProfileTitleValueCell";
static NSString * const kProfileTableViewCellSubtitleIdentifier     = @"ProfileSubtitleCell";

// Regular Expressions
static NSString * const kProfileTableViewCellNameRegEx              = @"[A-Za-z]";
static NSString * const kProfileTableViewCellUserNameRegEx          = @"[A-Za-z0-9_.]";
static NSString * const kProfileTableViewCellEmailRegEx             = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
static NSString * const kProfileTableViewCellWeightRegEx            = @"[0-9.]";

// PlaceHolders
static NSString * const kProfileTableViewCellNamePlaceholder        = @"Name";
static NSString * const kProfileTableViewCellUserNamePlaceholder    = @"User Name";
static NSString * const kProfileTableViewCellEmailPlaceholder       = @"Email";
static NSString * const kProfileTableViewCellWeightPlaceHolder      = @"Weight";

// Cell Title
static NSString * const kProfileTableViewCellBirthdayTitle          = @"Birthday";
static NSString * const kProfileTableViewCellMedicalConditionTitle  = @"Medical Condition";
static NSString * const kProfileTableViewCellMedicationTitle        = @"Medication";
static NSString * const kProfileTableViewCellBloodType              = @"Blood Type";
static NSString * const kProfileTableViewCellWeightTitle            = @"Weight";

// Date Formatter
static NSString * const kProfileTableViewCellDateOfBirthFormat      = @"MMM dd, yyyy";


typedef NS_ENUM(NSUInteger, ProfileTableViewCellOrder) {
    ProfileTableViewCellOrderName = 0,
    ProfileTableViewCellOrderUserName,
    ProfileTableViewCellOrderEmail,
    ProfileTableViewCellOrderDateOfBirth,
    ProfileTableViewCellOrderMedicalCondition,
    ProfileTableViewCellOrderMedication,
    ProfileTableViewCellOrderBloodType,
    ProfileTableViewCellOrderWeight
};

@interface ProfileViewController () <UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, ProfileCellDelegate>

@property (weak, nonatomic) IBOutlet UIView *footerConsentView;
@property (weak, nonatomic) IBOutlet UILabel *footerDiseaseLabel;
@property (weak, nonatomic) IBOutlet UILabel *studyPeriodLabel;
@property (weak, nonatomic) IBOutlet UIButton *reviewConsentButton;
@property (weak, nonatomic) IBOutlet UIButton *leaveStudyButton;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;

@property (nonatomic, strong) UITableView *profileTableView;

@property (nonatomic, strong) NSArray *medicalConditions;
@property (nonatomic, strong) NSArray *medications;
@property (nonatomic, strong) NSArray *bloodTypes;

@property (nonatomic, strong) Profile *profile;

@end

@implementation ProfileViewController

- (void) loadView {
    self.view = [[UIView alloc] initWithFrame:UIScreen.mainScreen.bounds];
}
            
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.title = @"Profile";
    
    [self loadValues];
    [self addTableView];
    [self addFooterView];
}

#pragma mark - UI Methods

- (void) loadValues {
    self.medicalConditions = @[@"Not listed", @"Condition 1" , @"Condition 2"];
    self.medications = @[@"Not listed", @"Medication 1" , @"Medication 2"];
    self.bloodTypes = @[@"O", @"O+", @"A-", @"A+", @"B-", @"B+", @"AB-", @"AB+"];
    
    
    self.profile = [Profile new];
    self.profile.firstName = @"Karthik Keyan";
    self.profile.lastName = @"Balan";
    self.profile.userName = @"karthikkeyan";
    self.profile.email = @"karthikkeyan.balan@gmail.com";
    self.profile.dateOfBirth = [NSDate date];
    self.profile.medicalCondition = self.medicalConditions[0];
    self.profile.medication = self.medications[0];
    self.profile.bloodType = self.bloodTypes[0];
    self.profile.weight = @(160);
}

- (void) addTableView {
    CGRect frame = self.view.bounds;
    frame.size.height -= 64;
    frame.origin.y = 64;
    
    self.profileTableView = [UITableView new];
    self.profileTableView.frame = frame;
    self.profileTableView.delegate = self;
    self.profileTableView.dataSource = self;
    self.profileTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.profileTableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    [self.view addSubview:self.profileTableView];
}

- (void) addFooterView {
    UIView *footerView = [[UINib nibWithNibName:@"ProfileTableFooterView" bundle:nil] instantiateWithOwner:self options:nil][0];
    self.profileTableView.tableFooterView = footerView;
    
    UIColor *color = [UIColor colorWithWhite:0.8 alpha:0.5];
    
    self.footerConsentView.layer.borderWidth = 1.0;
    self.footerConsentView.layer.borderColor = color.CGColor;
    
    self.reviewConsentButton.layer.borderWidth = 1.0;
    self.reviewConsentButton.layer.borderColor = color.CGColor;
    
    self.leaveStudyButton.layer.borderWidth = 1.0;
    self.leaveStudyButton.layer.borderColor = color.CGColor;
}


#pragma mark - UITableViewDataSource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 8;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ProfileCell *cell;
    
    switch (indexPath.row) {
        case ProfileTableViewCellOrderName:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:kProfileTableViewCellImageTextIdentifier];
            if (!cell) {
                cell = [[ProfileCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kProfileTableViewCellImageTextIdentifier type:ProfileCellTypeImageText];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            cell.valueTextRegularExpression = kProfileTableViewCellNameRegEx;
            cell.valueTextField.placeholder = kProfileTableViewCellNamePlaceholder;
            cell.valueTextField.text = self.profile.firstName;
        } break;
            
        case ProfileTableViewCellOrderUserName:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:kProfileTableViewCellTextIdentifier];
            if (!cell) {
                cell = [[ProfileCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kProfileTableViewCellTextIdentifier type:ProfileCellTypeSingleInputText];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            cell.valueTextRegularExpression = kProfileTableViewCellUserNameRegEx;
            cell.valueTextField.placeholder = kProfileTableViewCellUserNamePlaceholder;
            cell.valueTextField.text = self.profile.userName;
        } break;
            
        case ProfileTableViewCellOrderEmail:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:kProfileTableViewCellTextIdentifier];
            if (!cell) {
                cell = [[ProfileCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kProfileTableViewCellTextIdentifier type:ProfileCellTypeSingleInputText];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            cell.valueTextRegularExpression = kProfileTableViewCellEmailRegEx;
            cell.valueTextField.placeholder = kProfileTableViewCellEmailPlaceholder;
            cell.valueTextField.text = self.profile.email;
            cell.valueTextField.keyboardType = UIKeyboardTypeEmailAddress;
        } break;
            
        case ProfileTableViewCellOrderDateOfBirth:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:kProfileTableViewCellDateIdentifier];
            if (!cell) {
                cell = [[ProfileCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kProfileTableViewCellDateIdentifier type:ProfileCellTypeDatePicker];
            }
            
            cell.textLabel.text = kProfileTableViewCellBirthdayTitle;
            cell.valueTextField.text = [self.profile dateOfBirthStringWithFormat:kProfileTableViewCellDateOfBirthFormat];
        } break;
            
        case ProfileTableViewCellOrderMedicalCondition:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:kProfileTableViewCellSubtitleIdentifier];
            if (!cell) {
                cell = [[ProfileCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kProfileTableViewCellSubtitleIdentifier type:ProfileCellTypeNone];
                [cell setNeedsCustomPicker];
                [cell setNeedsHiddenField];
            }
            
            cell.textLabel.text = kProfileTableViewCellMedicalConditionTitle;
            cell.detailTextLabel.text = self.profile.medicalCondition;
            
            cell.customPickerValues = self.medicalConditions;
        } break;
            
        case ProfileTableViewCellOrderMedication:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:kProfileTableViewCellSubtitleIdentifier];
            if (!cell) {
                cell = [[ProfileCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kProfileTableViewCellSubtitleIdentifier type:ProfileCellTypeNone];
                [cell setNeedsCustomPicker];
                [cell setNeedsHiddenField];
            }
            
            cell.textLabel.text = kProfileTableViewCellMedicationTitle;
            cell.detailTextLabel.text = self.profile.medication;
            
            cell.customPickerValues = self.medications;
        } break;
            
        case ProfileTableViewCellOrderBloodType:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:kProfileTableViewCellTitleValueIdentifier];
            if (!cell) {
                cell = [[ProfileCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kProfileTableViewCellTitleValueIdentifier type:ProfileCellTypeTitleValue];
                [cell setNeedsCustomPicker];
            }
            
            cell.textLabel.text = kProfileTableViewCellBloodType;
            cell.valueTextField.text = self.profile.bloodType;
            cell.customPickerValues = self.bloodTypes;
        } break;
            
        case ProfileTableViewCellOrderWeight:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:kProfileTableViewCellTitleValueIdentifier];
            if (!cell) {
                cell = [[ProfileCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kProfileTableViewCellTitleValueIdentifier type:ProfileCellTypeTitleValue];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            cell.textLabel.text = kProfileTableViewCellWeightTitle;
            cell.valueTextRegularExpression = kProfileTableViewCellWeightRegEx;
            cell.valueTextField.placeholder = kProfileTableViewCellWeightPlaceHolder;
            cell.valueTextField.text = self.profile.weight.stringValue;
            cell.valueTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        } break;
            
        default:
            break;
    }
    
    cell.delegate = self;
    
    return cell;
}


#pragma mark - UITableViewDelegate

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 64;
    
    if (indexPath.row == 0) {
        height = 90;
    }
    
    return height;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ProfileCell *cell = (ProfileCell *)[tableView cellForRowAtIndexPath:indexPath];
    switch (cell.type) {
        case ProfileCellTypeNone:
        case ProfileCellTypeDatePicker:
        case ProfileCellTypeCustomPicker:
        case ProfileCellTypeTitleValue:
            [cell.valueTextField becomeFirstResponder];
            break;
            
        default:
            break;
    }
}


#pragma mark - UIImagePickerControllerDelegate

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = info[UIImagePickerControllerEditedImage];
    if (!image) {
        image = info[UIImagePickerControllerOriginalImage];
    }
    
    ProfileCell *cell = (ProfileCell *)[self.profileTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [cell.profileImageButton setImage:image forState:UIControlStateNormal];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - InputCellDelegate

- (void) profileCellValueChanged:(ProfileCell *)cell {
    NSIndexPath *indexPath = [self.profileTableView indexPathForCell:cell];
    
    switch (indexPath.row) {
        case ProfileTableViewCellOrderName:
            self.profile.firstName = cell.valueTextField.text;
            break;
            
        case ProfileTableViewCellOrderUserName:
            self.profile.userName = cell.valueTextField.text;
            break;
            
        case ProfileTableViewCellOrderEmail:
            self.profile.email = cell.valueTextField.text;
            break;
            
        case ProfileTableViewCellOrderDateOfBirth:
            self.profile.dateOfBirth = cell.datePicker.date;
            break;
            
        case ProfileTableViewCellOrderMedicalCondition:
            self.profile.medicalCondition = self.medicalConditions[[cell.customPickerView selectedRowInComponent:0]];
            break;
            
        case ProfileTableViewCellOrderMedication:
            self.profile.medication = self.medications[[cell.customPickerView selectedRowInComponent:0]];
            break;
            
        case ProfileTableViewCellOrderBloodType:
            self.profile.bloodType = self.bloodTypes[[cell.customPickerView selectedRowInComponent:0]];
            break;
            
        case ProfileTableViewCellOrderWeight:
            self.profile.weight = @([cell.valueTextField.text integerValue]);
            break;
            
        default:
            break;
    }
    
    [self.profileTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void) profileCellDidSelectProfileImage:(ProfileCell *)cell {
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


#pragma mark - IBActions

- (IBAction) reviewConsent {
    
}


- (IBAction) leaveStudy {
    
}

- (IBAction) logout {
    
}


#pragma mark - NSNotification

- (void) keyboardWillShow:(NSNotification *)notification {
    
}

- (void) keyboardWillHide:(NSNotification *)notification {
    
}

@end
