//
//  ViewController.m
//  Profile
//
//  Created by Karthik Keyan on 8/22/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCProfile.h"
#import "NSDate+Category.h"
#import "NSString+Category.h"
#import "APCUserInfoViewController.h"

// Cell Identifiers
static NSString * const kAPCUserInfoTableViewCellImageTextIdentifier    = @"ImageTextCell";
static NSString * const kAPCUserInfoTableViewCellTextIdentifier         = @"TextCell";
static NSString * const kAPCUserInfoTableViewCellDateIdentifier         = @"DateCell";
static NSString * const kAPCUserInfoTableViewCellTitleValueIdentifier   = @"TitleValueCell";
static NSString * const kAPCUserInfoTableViewCellSubtitleIdentifier     = @"SubtitleCell";
static NSString * const kAPCUserInfoTableViewCellSegmentIdentifier      = @"SegmentCell";

// Regular Expressions
static NSString * const kAPCUserInfoTableViewCellNameRegEx              = @"[A-Za-z]";
static NSString * const kAPCUserInfoTableViewCellUserNameRegEx          = @"[A-Za-z0-9_.]";
static NSString * const kAPCUserInfoTableViewCellEmailRegEx             = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
static NSString * const kAPCUserInfoTableViewCellWeightRegEx            = @"[0-9]{1,3}";

// PlaceHolders
static NSString * const kAPCUserInfoTableViewCellNamePlaceholder        = @"Name";
static NSString * const kAPCUserInfoTableViewCellUserNamePlaceholder    = @"User Name";
static NSString * const kAPCUserInfoTableViewCellEmailPlaceholder       = @"Email";
static NSString * const kAPCUserInfoTableViewCellPasswordPlaceholder    = @"Password";
static NSString * const kAPCUserInfoTableViewCellWeightPlaceHolder      = @"lb";

// Cell Title
static NSString * const kAPCUserInfoTableViewCellBirthdayTitle          = @"Birthday";
static NSString * const kAPCUserInfoTableViewCellMedicalConditionTitle  = @"Medical Condition";
static NSString * const kAPCUserInfoTableViewCellMedicationTitle        = @"Medication";
static NSString * const kAPCUserInfoTableViewCellBloodType              = @"Blood Type";
static NSString * const kAPCUserInfoTableViewCellWeightTitle            = @"Weight";
static NSString * const kAPCUserInfoTableViewCellHeightTitle            = @"Height";
static NSString * const kAPCUserInfoTableViewCellGenderTitle            = @"Biological Sex";

// Date Formatter
static NSString * const kAPCUserInfoTableViewCellDateOfBirthFormat      = @"MMM dd, yyyy";


@interface APCUserInfoViewController ()

@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UIView *headerTextFieldSeparatorView;

@end

@implementation APCUserInfoViewController

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
    _medicalConditions = @[
                           @[@"Not listed", @"Condition 1" , @"Condition 2"]
                           ];
    
    _medications = @[
                     @[@"Not listed", @"Medication 1" , @"Medication 2"]
                      ];
    
    _bloodTypes = @[ 
                    @[@"O-", @"O+", @"A-", @"A+", @"B-", @"B+", @"AB-", @"AB+"]
                     ];
    
    _heightValues = @[
                      @[@"3'", @"4'", @"5'", @"6'", @"7'"],
                      @[@"0''", @"1''", @"2''", @"3''", @"4''", @"5''", @"6''", @"7''", @"8''", @"9''"]
                       ];
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
    self.lastNameTextField.text = self.profile.lastName;
}


#pragma mark - UITableViewDataSource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.fields.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    APCUserInfoCell *cell;
    
    APCUserInfoField field = [self.fields[indexPath.row] integerValue];
    
    switch (field) {
        case APCUserInfoFieldUserName:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:kAPCUserInfoTableViewCellTextIdentifier];
            if (!cell) {
                cell = [[APCUserInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kAPCUserInfoTableViewCellTextIdentifier type:APCUserInfoCellTypeSingleInputText];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            cell.valueTextField.placeholder = kAPCUserInfoTableViewCellUserNamePlaceholder;
            cell.valueTextRegularExpression = kAPCUserInfoTableViewCellUserNameRegEx;
            cell.valueTextField.text = self.profile.userName;
            cell.valueTextField.keyboardType = UIKeyboardTypeEmailAddress;
        } break;
            
        case APCUserInfoFieldEmail:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:kAPCUserInfoTableViewCellTextIdentifier];
            if (!cell) {
                cell = [[APCUserInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kAPCUserInfoTableViewCellTextIdentifier type:APCUserInfoCellTypeSingleInputText];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            cell.valueTextField.placeholder = kAPCUserInfoTableViewCellEmailPlaceholder;
            cell.valueTextField.text = self.profile.email;
            cell.valueTextField.keyboardType = UIKeyboardTypeEmailAddress;
        } break;
            
        case APCUserInfoFieldPassword:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:kAPCUserInfoTableViewCellTextIdentifier];
            if (!cell) {
                cell = [[APCUserInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kAPCUserInfoTableViewCellTextIdentifier type:APCUserInfoCellTypeSingleInputText];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            cell.valueTextField.placeholder = kAPCUserInfoTableViewCellPasswordPlaceholder;
            cell.valueTextField.text = self.profile.password;
            cell.valueTextField.keyboardType = UIKeyboardTypeDefault;
            cell.valueTextField.secureTextEntry = YES;
        } break;
            
        case APCUserInfoFieldDateOfBirth:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:kAPCUserInfoTableViewCellDateIdentifier];
            if (!cell) {
                cell = [[APCUserInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kAPCUserInfoTableViewCellDateIdentifier type:APCUserInfoCellTypeDatePicker];
            }
            
            cell.textLabel.text = kAPCUserInfoTableViewCellBirthdayTitle;
            if (self.profile.dateOfBirth) {
                cell.valueTextField.text = [self.profile.dateOfBirth toStringWithFormat:kAPCUserInfoTableViewCellDateOfBirthFormat];
            }
        } break;
            
        case APCUserInfoFieldMedicalCondition:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:kAPCUserInfoTableViewCellSubtitleIdentifier];
            if (!cell) {
                cell = [[APCUserInfoCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kAPCUserInfoTableViewCellSubtitleIdentifier type:APCUserInfoCellTypeNone];
                [cell setNeedsCustomPicker];
                [cell setNeedsHiddenField];
            }
            
            cell.textLabel.text = kAPCUserInfoTableViewCellMedicalConditionTitle;
            cell.detailTextLabel.text = self.profile.medicalCondition;
            
            cell.customPickerValues = self.medicalConditions;
        } break;
            
        case APCUserInfoFieldMedication:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:kAPCUserInfoTableViewCellSubtitleIdentifier];
            if (!cell) {
                cell = [[APCUserInfoCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kAPCUserInfoTableViewCellSubtitleIdentifier type:APCUserInfoCellTypeNone];
                [cell setNeedsCustomPicker];
                [cell setNeedsHiddenField];
            }
            
            cell.textLabel.text = kAPCUserInfoTableViewCellMedicationTitle;
            cell.detailTextLabel.text = self.profile.medication;
            
            cell.customPickerValues = self.medications;
        } break;
            
        case APCUserInfoFieldBloodType:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:kAPCUserInfoTableViewCellTitleValueIdentifier];
            if (!cell) {
                cell = [[APCUserInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kAPCUserInfoTableViewCellTitleValueIdentifier type:APCUserInfoCellTypeTitleValue];
                [cell setNeedsCustomPicker];
            }
            
            cell.textLabel.text = kAPCUserInfoTableViewCellBloodType;
            cell.valueTextField.text = self.profile.bloodType;
            cell.customPickerValues = self.bloodTypes;
        } break;
            
        case APCUserInfoFieldHeight:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:kAPCUserInfoTableViewCellTitleValueIdentifier];
            if (!cell) {
                cell = [[APCUserInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kAPCUserInfoTableViewCellTitleValueIdentifier type:APCUserInfoCellTypeTitleValue];
                [cell setNeedsCustomPicker];
            }
            
            cell.textLabel.text = kAPCUserInfoTableViewCellHeightTitle;
            cell.valueTextField.text = self.profile.height;
            cell.customPickerValues = self.heightValues;
        } break;
            
        case APCUserInfoFieldWeight:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:kAPCUserInfoTableViewCellTitleValueIdentifier];
            if (!cell) {
                cell = [[APCUserInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kAPCUserInfoTableViewCellTitleValueIdentifier type:APCUserInfoCellTypeTitleValue];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            cell.textLabel.text = kAPCUserInfoTableViewCellWeightTitle;
            cell.valueTextRegularExpression = kAPCUserInfoTableViewCellWeightRegEx;
            cell.valueTextField.placeholder = kAPCUserInfoTableViewCellWeightPlaceHolder;
            cell.valueTextField.text = self.profile.weight.stringValue;
            cell.valueTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        } break;
            
        case APCUserInfoFieldGender:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:kAPCUserInfoTableViewCellSegmentIdentifier];
            if (!cell) {
                cell = [[APCUserInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kAPCUserInfoTableViewCellSegmentIdentifier type:APCUserInfoCellTypeSegment];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            cell.textLabel.text = kAPCUserInfoTableViewCellGenderTitle;
            
            [cell.segmentControl insertSegmentWithTitle:@"Male" atIndex:0 animated:NO];
            [cell.segmentControl insertSegmentWithTitle:@"Female" atIndex:1 animated:NO];
            [cell.segmentControl insertSegmentWithTitle:@"Other" atIndex:2 animated:NO];
            
            [cell.segmentControl setSelectedSegmentIndex:self.profile.gender];
        } break;
            
        default:
            break;
    }
    
    cell.delegate = self;
    
    return cell;
}


#pragma mark - UITableViewDelegate

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 54;
    APCUserInfoField field = [self.fields[indexPath.row] integerValue];
    
    if (field == APCUserInfoFieldGender) {
        height += 20;
    }
    
    return height;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    APCUserInfoCell *cell = (APCUserInfoCell *)[tableView cellForRowAtIndexPath:indexPath];
    switch (cell.type) {
        case APCUserInfoCellTypeNone:
        case APCUserInfoCellTypeDatePicker:
        case APCUserInfoCellTypeCustomPicker:
        case APCUserInfoCellTypeTitleValue:
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
    
    APCUserInfoCell *cell = (APCUserInfoCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
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
            isValid = [text isValidForRegex:kAPCUserInfoTableViewCellNameRegEx];
        }
        else {
            isValid = [text isValidForRegex:kAPCUserInfoTableViewCellUserNameRegEx];
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

- (void) APCUserInfoCellValueChanged:(APCUserInfoCell *)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    if (indexPath) {
        APCUserInfoField field = [self.fields[indexPath.row] integerValue];
        
        switch (field) {
            case APCUserInfoFieldEmail:
                self.profile.email = cell.valueTextField.text;
                break;
                
            case APCUserInfoFieldDateOfBirth:
                self.profile.dateOfBirth = cell.datePicker.date;
                break;
                
            case APCUserInfoFieldMedicalCondition:
                self.profile.medicalCondition =  cell.valueTextField.text;
                break;
                
            case APCUserInfoFieldMedication:
                self.profile.medication = cell.valueTextField.text;
                break;
                
            case APCUserInfoFieldBloodType:
                self.profile.bloodType = cell.valueTextField.text;
                break;
                
            case APCUserInfoFieldWeight:
                self.profile.weight = @([cell.valueTextField.text integerValue]);
                break;
                
            case APCUserInfoFieldHeight:
                self.profile.height = cell.valueTextField.text;
                break;
                
            case APCUserInfoFieldPassword:
                self.profile.password = cell.valueTextField.text;
                break;
                
            case APCUserInfoFieldGender:
                self.profile.gender = (APCProfileGender)cell.segmentControl.selectedSegmentIndex;
                
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
