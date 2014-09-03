//
//  ViewController.m
//  Profile
//
//  Created by Karthik Keyan on 8/22/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "Profile.h"
#import "NSString+Extension.h"
#import "UserInfoViewController.h"

// Cell Identifiers
static NSString * const kUserInfoTableViewCellImageTextIdentifier    = @"ImageTextCell";
static NSString * const kUserInfoTableViewCellTextIdentifier         = @"TextCell";
static NSString * const kUserInfoTableViewCellDateIdentifier         = @"DateCell";
static NSString * const kUserInfoTableViewCellTitleValueIdentifier   = @"TitleValueCell";
static NSString * const kUserInfoTableViewCellSubtitleIdentifier     = @"SubtitleCell";
static NSString * const kUserInfoTableViewCellSegmentIdentifier      = @"SegmentCell";

// Regular Expressions
static NSString * const kUserInfoTableViewCellNameRegEx              = @"[A-Za-z]";
static NSString * const kUserInfoTableViewCellUserNameRegEx          = @"[A-Za-z0-9_.]";
static NSString * const kUserInfoTableViewCellEmailRegEx             = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
static NSString * const kUserInfoTableViewCellWeightRegEx            = @"[0-9]{1,3}";

// PlaceHolders
static NSString * const kUserInfoTableViewCellNamePlaceholder        = @"Name";
static NSString * const kUserInfoTableViewCellUserNamePlaceholder    = @"User Name";
static NSString * const kUserInfoTableViewCellEmailPlaceholder       = @"Email";
static NSString * const kUserInfoTableViewCellPasswordPlaceholder    = @"Password";
static NSString * const kUserInfoTableViewCellWeightPlaceHolder      = @"lb";

// Cell Title
static NSString * const kUserInfoTableViewCellBirthdayTitle          = @"Birthday";
static NSString * const kUserInfoTableViewCellMedicalConditionTitle  = @"Medical Condition";
static NSString * const kUserInfoTableViewCellMedicationTitle        = @"Medication";
static NSString * const kUserInfoTableViewCellBloodType              = @"Blood Type";
static NSString * const kUserInfoTableViewCellWeightTitle            = @"Weight";
static NSString * const kUserInfoTableViewCellHeightTitle            = @"Height";
static NSString * const kUserInfoTableViewCellGenderTitle            = @"Biological Sex";

// Date Formatter
static NSString * const kUserInfoTableViewCellDateOfBirthFormat      = @"MMM dd, yyyy";


@interface UserInfoViewController ()

@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UIView *headerTextFieldSeparatorView;

@end

@implementation UserInfoViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self loadValues];
    }
    
    return self;
}

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
    [self addHeaderView];
}

#pragma mark - UI Methods

- (void) loadValues {
    _medicalConditions = @[ @[@"Not listed", @"Condition 1" , @"Condition 2"] ];
    _medications = @[ @[@"Not listed", @"Medication 1" , @"Medication 2"] ];
    _bloodTypes = @[ @[@"O-", @"O+", @"A-", @"A+", @"B-", @"B+", @"AB-", @"AB+"] ];
    _heightValues = @[ @[@"3'", @"4'", @"5'", @"6'", @"7'"], @[@"0''", @"1''", @"2''", @"3''", @"4''", @"5''", @"6''", @"7''", @"8''", @"9''"] ];
}

- (void) addTableView {
    CGRect frame = self.view.bounds;
    frame.size.height -= 64;
    frame.origin.y = 64;
    
    self.tableView = [UITableView new];
    self.tableView.frame = frame;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    [self.view addSubview:self.tableView];
}

- (void) addHeaderView {
    UIView *headerView = [[UINib nibWithNibName:@"UserInfoTableHeaderView" bundle:nil] instantiateWithOwner:self options:nil][0];
    self.tableView.tableHeaderView = headerView;
    
    CGRect frame = self.headerTextFieldSeparatorView.frame;
    frame.size.height = 0.25;
    
    self.headerTextFieldSeparatorView.frame = frame;
    self.headerTextFieldSeparatorView.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.6];
    
    self.profileImageView.layer.cornerRadius = 30;
    self.profileImageView.layer.borderColor = [UIColor colorWithWhite:0.5 alpha:0.6].CGColor;
    self.profileImageView.layer.borderWidth = 1.0;
    
    self.firstNameTextField.text = self.profile.firstName;
    self.userNameTextField.text = self.profile.userName;
}


#pragma mark - UITableViewDataSource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.fields.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserInfoCell *cell;
    
    UserInfoField field = [self.fields[indexPath.row] integerValue];
    
    switch (field) {
        case UserInfoFieldEmail:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:kUserInfoTableViewCellTextIdentifier];
            if (!cell) {
                cell = [[UserInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kUserInfoTableViewCellTextIdentifier type:ProfileCellTypeSingleInputText];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            cell.valueTextField.placeholder = kUserInfoTableViewCellEmailPlaceholder;
            cell.valueTextField.text = self.profile.email;
            cell.valueTextField.keyboardType = UIKeyboardTypeEmailAddress;
        } break;
            
        case UserInfoFieldPassword:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:kUserInfoTableViewCellTextIdentifier];
            if (!cell) {
                cell = [[UserInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kUserInfoTableViewCellTextIdentifier type:ProfileCellTypeSingleInputText];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            cell.valueTextField.placeholder = kUserInfoTableViewCellPasswordPlaceholder;
            cell.valueTextField.text = self.profile.password;
            cell.valueTextField.keyboardType = UIKeyboardTypeDefault;
            cell.valueTextField.secureTextEntry = YES;
        } break;
            
        case UserInfoFieldDateOfBirth:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:kUserInfoTableViewCellDateIdentifier];
            if (!cell) {
                cell = [[UserInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kUserInfoTableViewCellDateIdentifier type:ProfileCellTypeDatePicker];
            }
            
            cell.textLabel.text = kUserInfoTableViewCellBirthdayTitle;
            cell.valueTextField.text = [self.profile dateOfBirthStringWithFormat:kUserInfoTableViewCellDateOfBirthFormat];
        } break;
            
        case UserInfoFieldMedicalCondition:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:kUserInfoTableViewCellSubtitleIdentifier];
            if (!cell) {
                cell = [[UserInfoCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kUserInfoTableViewCellSubtitleIdentifier type:ProfileCellTypeNone];
                [cell setNeedsCustomPicker];
                [cell setNeedsHiddenField];
            }
            
            cell.textLabel.text = kUserInfoTableViewCellMedicalConditionTitle;
            cell.detailTextLabel.text = self.profile.medicalCondition;
            
            cell.customPickerValues = self.medicalConditions;
        } break;
            
        case UserInfoFieldMedication:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:kUserInfoTableViewCellSubtitleIdentifier];
            if (!cell) {
                cell = [[UserInfoCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kUserInfoTableViewCellSubtitleIdentifier type:ProfileCellTypeNone];
                [cell setNeedsCustomPicker];
                [cell setNeedsHiddenField];
            }
            
            cell.textLabel.text = kUserInfoTableViewCellMedicationTitle;
            cell.detailTextLabel.text = self.profile.medication;
            
            cell.customPickerValues = self.medications;
        } break;
            
        case UserInfoFieldBloodType:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:kUserInfoTableViewCellTitleValueIdentifier];
            if (!cell) {
                cell = [[UserInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kUserInfoTableViewCellTitleValueIdentifier type:ProfileCellTypeTitleValue];
                [cell setNeedsCustomPicker];
            }
            
            cell.textLabel.text = kUserInfoTableViewCellBloodType;
            cell.valueTextField.text = self.profile.bloodType;
            cell.customPickerValues = self.bloodTypes;
        } break;
            
        case UserInfoFieldHeight:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:kUserInfoTableViewCellTitleValueIdentifier];
            if (!cell) {
                cell = [[UserInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kUserInfoTableViewCellTitleValueIdentifier type:ProfileCellTypeTitleValue];
                [cell setNeedsCustomPicker];
            }
            
            cell.textLabel.text = kUserInfoTableViewCellHeightTitle;
            cell.valueTextField.text = self.profile.height;
            cell.customPickerValues = self.heightValues;
        } break;
            
        case UserInfoFieldWeight:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:kUserInfoTableViewCellTitleValueIdentifier];
            if (!cell) {
                cell = [[UserInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kUserInfoTableViewCellTitleValueIdentifier type:ProfileCellTypeTitleValue];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            cell.textLabel.text = kUserInfoTableViewCellWeightTitle;
            cell.valueTextRegularExpression = kUserInfoTableViewCellWeightRegEx;
            cell.valueTextField.placeholder = kUserInfoTableViewCellWeightPlaceHolder;
            cell.valueTextField.text = self.profile.weight.stringValue;
            cell.valueTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        } break;
            
        case UserInfoFieldGender:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:kUserInfoTableViewCellSegmentIdentifier];
            if (!cell) {
                cell = [[UserInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kUserInfoTableViewCellSegmentIdentifier type:ProfileCellTypeSegment];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            cell.textLabel.text = kUserInfoTableViewCellGenderTitle;
            
            [cell.segmentControl insertSegmentWithTitle:@"Male" atIndex:0 animated:NO];
            [cell.segmentControl insertSegmentWithTitle:@"Female" atIndex:1 animated:NO];
            [cell.segmentControl insertSegmentWithTitle:@"Other" atIndex:2 animated:NO];
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
    UserInfoField field = [self.fields[indexPath.row] integerValue];
    
    if (field == UserInfoFieldGender) {
        height = 80;
    }
    
    return height;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UserInfoCell *cell = (UserInfoCell *)[tableView cellForRowAtIndexPath:indexPath];
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
    
    UserInfoCell *cell = (UserInfoCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [cell.profileImageButton setImage:image forState:UIControlStateNormal];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - UITextFieldDelegate

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    BOOL isValid = YES;
    
    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (text.length > 0) {
        if ([textField isEqual:self.firstNameTextField]) {
            isValid = [text isValidForRegex:kUserInfoTableViewCellNameRegEx];
        }
        else {
            isValid = [text isValidForRegex:kUserInfoTableViewCellUserNameRegEx];
        }
    }
    
    return isValid;
}

- (void) textFieldDidEndEditing:(UITextField *)textField {
    if ([textField isEqual:self.firstNameTextField]) {
        self.profile.firstName = textField.text;
    }
    else {
        self.profile.userName = textField.text;
    }
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    return YES;
}



#pragma mark - InputCellDelegate

- (void) profileCellValueChanged:(UserInfoCell *)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    if (indexPath) {
        UserInfoField field = [self.fields[indexPath.row] integerValue];
        
        switch (field) {
            case UserInfoFieldEmail:
                self.profile.email = cell.valueTextField.text;
                break;
                
            case UserInfoFieldDateOfBirth:
                self.profile.dateOfBirth = cell.datePicker.date;
                break;
                
            case UserInfoFieldMedicalCondition:
                self.profile.medicalCondition =  cell.valueTextField.text;
                break;
                
            case UserInfoFieldMedication:
                self.profile.medication = cell.valueTextField.text;
                break;
                
            case UserInfoFieldBloodType:
                self.profile.bloodType = cell.valueTextField.text;
                break;
                
            case UserInfoFieldWeight:
                self.profile.weight = @([cell.valueTextField.text integerValue]);
                break;
                
            case UserInfoFieldHeight:
                self.profile.height = cell.valueTextField.text;
                break;
                
            case UserInfoFieldPassword:
                self.profile.password = cell.valueTextField.text;
                break;
                
            default:
                break;
        }
        
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}


#pragma mark - IBActions

- (IBAction) profileImageViewTapped:(UITapGestureRecognizer *)sender {
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


#pragma mark - NSNotification

- (void) keyboardWillShow:(NSNotification *)notification {
    
}

- (void) keyboardWillHide:(NSNotification *)notification {
    
}

@end
