//
//  ViewController.m
//  Profile
//
//  Created by Karthik Keyan on 8/22/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCProfile.h"
#import "APCHKManager.h"
#import "NSDate+Category.h"
#import "NSString+Category.h"
#import "UIScrollView+Category.h"
#import "APCUserInfoViewController.h"
#import "UITableView+AppearanceCategory.h"

// Cell Identifiers
static NSString * const kAPCUserInfoTableViewCellImageTextIdentifier    = @"ImageTextCell";
static NSString * const kAPCUserInfoTableViewCellTextIdentifier         = @"TextCell";
static NSString * const kAPCUserInfoTableViewCellPasswordIdentifier     = @"PasswordCell";
static NSString * const kAPCUserInfoTableViewCellDateIdentifier         = @"DateCell";
static NSString * const kAPCUserInfoTableViewCellCustomPickerIdentifier = @"CustomPickerCell";
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
static NSString * const kAPCUserInfoTableViewCellUserNamePlaceholder    = @"Add Username";
static NSString * const kAPCUserInfoTableViewCellEmailPlaceholder       = @"Add Email Address";
static NSString * const kAPCUserInfoTableViewCellPasswordPlaceholder    = @"Password";
static NSString * const kAPCUserInfoTableViewCellWeightPlaceHolder      = @"lb";

// Cell Title
static NSString * const kAPCUserInfoTableViewCellUserNameTitle          = @"Username";
static NSString * const kAPCUserInfoTableViewCellEmailTitle             = @"Email";
static NSString * const kAPCUserInfoTableViewCellPasswordTitle          = @"Password";
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

@property (nonatomic, strong) APCHKManager *hkManager;

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
    [self loadHealthKitValues];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - UI Methods

- (void) loadValues {
    _medicalConditions = @[ @[@"Not listed", @"Condition 1" , @"Condition 2"] ];
    
    _medications = @[ @[@"Not listed", @"Medication 1" , @"Medication 2"] ];
    
    _bloodTypes = @[ @[@" ", @"A+", @"A-", @"B+", @"B-", @"AB+", @"AB-", @"O+", @"O-"] ];
    
    _heightValues = @[ @[@"3'", @"4'", @"5'", @"6'", @"7'"], @[@"0''", @"1''", @"2''", @"3''", @"4''", @"5''", @"6''", @"7''", @"8''", @"9''"] ];
    
    self.hkManager = [APCHKManager new];
}

- (void) addTableView {
    CGRect frame = self.view.bounds;
    frame.size.height -= 64;
    frame.origin.y = 64;
    
    self.tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    [self.view addSubview:self.tableView];
}

- (void) addHeaderView {
    UIView *headerView = [[UINib nibWithNibName:@"APCUserInfoTableHeaderView" bundle:nil] instantiateWithOwner:self options:nil][0];
    self.tableView.tableHeaderView = headerView;
    
    CGRect frame = self.headerTextFieldSeparatorView.frame;
    frame.size.height = 1;
    
    self.headerTextFieldSeparatorView.clipsToBounds = YES;
    self.headerTextFieldSeparatorView.frame = frame;
    self.headerTextFieldSeparatorView.backgroundColor = self.tableView.separatorColor;
    
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width/2;
    
    self.firstNameTextField.text = self.profile.firstName;
    self.lastNameTextField.text = self.profile.lastName;
    
    self.firstNameTextField.font = [UITableView textFieldFont];
    self.firstNameTextField.textColor = [UITableView textFieldTextColor];
    
    self.lastNameTextField.font = [UITableView textFieldFont];
    self.lastNameTextField.textColor = [UITableView textFieldTextColor];
}

- (void) loadHealthKitValues {
    typeof(self) __weak weakSelf = self;
    [self.hkManager authenticate:^(BOOL granted, NSError *error) {
        if (granted) {
            [weakSelf loadBiologicalInfo];
            [weakSelf loadHeight];
            [weakSelf loadWidth];
        }
    }];
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
            cell = [self cellForIdentifier:kAPCUserInfoTableViewCellTextIdentifier style:UITableViewCellStyleDefault];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.type = APCUserInfoCellTypeSingleInputText;
            
            cell.textLabel.text = kAPCUserInfoTableViewCellUserNameTitle;
            cell.valueTextField.placeholder = kAPCUserInfoTableViewCellUserNamePlaceholder;
            cell.valueTextField.text = self.profile.userName;
            cell.valueTextField.keyboardType = UIKeyboardTypeEmailAddress;
        } break;
            
        case APCUserInfoFieldEmail:
        {
            cell = [self cellForIdentifier:kAPCUserInfoTableViewCellTextIdentifier style:UITableViewCellStyleDefault];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.type = APCUserInfoCellTypeSingleInputText;
            cell.textLabel.text = kAPCUserInfoTableViewCellEmailTitle;
            cell.valueTextField.placeholder = kAPCUserInfoTableViewCellEmailPlaceholder;
            cell.valueTextField.text = self.profile.email;
            cell.valueTextField.keyboardType = UIKeyboardTypeEmailAddress;
        } break;
            
        case APCUserInfoFieldPassword:
        {
            cell = [self cellForIdentifier:kAPCUserInfoTableViewCellPasswordIdentifier style:UITableViewCellStyleDefault];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.type = APCUserInfoCellTypeSingleInputText;
            cell.textLabel.text = kAPCUserInfoTableViewCellPasswordTitle;
            cell.valueTextField.placeholder = kAPCUserInfoTableViewCellPasswordPlaceholder;
            cell.valueTextField.text = self.profile.password;
            cell.valueTextField.keyboardType = UIKeyboardTypeDefault;
            cell.valueTextField.secureTextEntry = YES;
        } break;
            
        case APCUserInfoFieldDateOfBirth:
        {
            cell = [self cellForIdentifier:kAPCUserInfoTableViewCellDateIdentifier style:UITableViewCellStyleDefault];
            
            cell.type = APCUserInfoCellTypeDatePicker;
            cell.textLabel.text = kAPCUserInfoTableViewCellBirthdayTitle;
            
            if (self.profile.dateOfBirth) {
                cell.valueTextField.text = [self.profile.dateOfBirth toStringWithFormat:kAPCUserInfoTableViewCellDateOfBirthFormat];
            }
        } break;
            
        case APCUserInfoFieldMedicalCondition:
        {
            cell = [self cellForIdentifier:kAPCUserInfoTableViewCellSubtitleIdentifier style:UITableViewCellStyleValue1];
            
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.type = APCUserInfoCellTypeNone;
            
            [cell setNeedsCustomPicker];
            [cell setNeedsHiddenField];
            
            cell.textLabel.text = kAPCUserInfoTableViewCellMedicalConditionTitle;
            cell.detailTextLabel.text = self.profile.medicalCondition;
            cell.customPickerValues = self.medicalConditions;
        } break;
            
        case APCUserInfoFieldMedication:
        {
            cell = [self cellForIdentifier:kAPCUserInfoTableViewCellSubtitleIdentifier style:UITableViewCellStyleValue1];
            
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.type = APCUserInfoCellTypeNone;
            
            [cell setNeedsCustomPicker];
            [cell setNeedsHiddenField];
            
            cell.textLabel.text = kAPCUserInfoTableViewCellMedicationTitle;
            cell.detailTextLabel.text = self.profile.medication;
            cell.customPickerValues = self.medications;
        } break;
            
        case APCUserInfoFieldBloodType:
        {
            cell = [self cellForIdentifier:kAPCUserInfoTableViewCellCustomPickerIdentifier style:UITableViewCellStyleDefault];
            
            cell.type = APCUserInfoCellTypeTitleValue;
            [cell setNeedsCustomPicker];
            
            cell.textLabel.text = kAPCUserInfoTableViewCellBloodType;
            cell.valueTextField.text = self.bloodTypes[0][self.profile.bloodType];
            cell.customPickerValues = self.bloodTypes;
        } break;
            
        case APCUserInfoFieldHeight:
        {
            cell = [self cellForIdentifier:kAPCUserInfoTableViewCellCustomPickerIdentifier style:UITableViewCellStyleDefault];
            
            cell.type = APCUserInfoCellTypeTitleValue;
            [cell setNeedsCustomPicker];
            
            cell.textLabel.text = kAPCUserInfoTableViewCellHeightTitle;
            cell.valueTextField.text = self.profile.height;
            cell.customPickerValues = self.heightValues;
        } break;
            
        case APCUserInfoFieldWeight:
        {
            cell = [self cellForIdentifier:kAPCUserInfoTableViewCellTitleValueIdentifier style:UITableViewCellStyleDefault];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.type = APCUserInfoCellTypeTitleValue;
            
            cell.textLabel.text = kAPCUserInfoTableViewCellWeightTitle;
            cell.valueTextRegularExpression = kAPCUserInfoTableViewCellWeightRegEx;
            cell.valueTextField.placeholder = kAPCUserInfoTableViewCellWeightPlaceHolder;
            cell.valueTextField.text = self.profile.weight.stringValue;
            cell.valueTextField.keyboardType = UIKeyboardTypeNumberPad;
        } break;
            
        case APCUserInfoFieldGender:
        {
            cell = [self cellForIdentifier:kAPCUserInfoTableViewCellSegmentIdentifier style:UITableViewCellStyleDefault];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.type = APCUserInfoCellTypeSegment;
            
            cell.textLabel.text = kAPCUserInfoTableViewCellGenderTitle;
            
            [cell.segmentControl insertSegmentWithTitle:@"Male" atIndex:0 animated:NO];
            [cell.segmentControl insertSegmentWithTitle:@"Female" atIndex:1 animated:NO];
            [cell.segmentControl insertSegmentWithTitle:@"Other" atIndex:2 animated:NO];
            
            if (self.profile.gender == HKBiologicalSexMale) {
                [cell.segmentControl setSelectedSegmentIndex:0];
            }
            else if (self.profile.gender == HKBiologicalSexFemale) {
                [cell.segmentControl setSelectedSegmentIndex:1];
            }
            else {
                [cell.segmentControl setSelectedSegmentIndex:2];
            }
        } break;
            
        default:
            break;
    }
    
    return cell;
}

- (APCUserInfoCell *) cellForIdentifier:(NSString *)identifier style:(UITableViewCellStyle)style {
    APCUserInfoCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[[self cellClass] alloc] initWithStyle:style reuseIdentifier:identifier];
    }
    
    cell.delegate = self;
    
    return cell;
}


#pragma mark - UITableViewDelegate

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64;
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


#pragma mark - InputCellDelegate

- (void) userInfoCellDidBecomFirstResponder:(APCUserInfoCell *)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

- (void) userInfoCellValueChanged:(APCUserInfoCell *)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    if (indexPath) {
        APCUserInfoField field = [self.fields[indexPath.row] integerValue];
        
        switch (field) {
            case APCUserInfoFieldEmail:
                self.profile.email = cell.valueTextField.text;
                break;
                
            case APCUserInfoFieldDateOfBirth:
                self.profile.dateOfBirth = cell.datePicker.date;
                cell.valueTextField.text = [self.profile.dateOfBirth toStringWithFormat:kAPCUserInfoTableViewCellDateOfBirthFormat];
                break;
                
            case APCUserInfoFieldMedicalCondition:
                self.profile.medicalCondition =  cell.valueTextField.text;
                cell.detailTextLabel.text = cell.valueTextField.text;
                break;
                
            case APCUserInfoFieldMedication:
                self.profile.medication = cell.valueTextField.text;
                cell.detailTextLabel.text = cell.valueTextField.text;
                break;
                
            case APCUserInfoFieldBloodType:
                self.profile.bloodType = (HKBloodType)[self.bloodTypes[0] indexOfObject:cell.valueTextField.text];
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
                if (cell.segmentControl.selectedSegmentIndex == 0) {
                    self.profile.gender = HKBiologicalSexMale;
                }
                else if (cell.segmentControl.selectedSegmentIndex == 1) {
                    self.profile.gender = HKBiologicalSexFemale;
                }
                else {
                    self.profile.gender = HKBiologicalSexNotSet;
                }
                
            default:
                break;
        }
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


#pragma mark - Private Methods

- (void) loadHeight {
    typeof(self) __weak weakSelf = self;
    [self.hkManager latestHeight:^(HKQuantity *quantity, NSError *error) {
        if (!error) {
            weakSelf.profile.height = [NSString stringWithFormat:@"%f", [quantity doubleValueForUnit:[HKUnit unitFromLengthFormatterUnit:NSLengthFormatterUnitInch]]];
            [weakSelf.tableView reloadData];
        }
    }];
}

- (void) loadWidth {
    typeof(self) __weak weakSelf = self;
    
    [self.hkManager latestHeight:^(HKQuantity *quantity, NSError *error) {
        if (!error) {
            weakSelf.profile.weight = @([quantity doubleValueForUnit:[HKUnit unitFromMassFormatterUnit:NSMassFormatterUnitKilogram]]);
            [weakSelf.tableView reloadData];
        }
    }];
}

- (void) loadBiologicalInfo {
    [self.hkManager fillBiologicalInfo:self.profile];
    [self.tableView reloadData];
}


#pragma mark - Public Methods

- (Class) cellClass {
    return [APCUserInfoCell class];
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
    [self.tableView reduceSizeForKeyboardShowNotification:notification];
}

- (void) keyboardWillHide:(NSNotification *)notification {
    [self.tableView resizeForKeyboardHideNotification:notification];
}

@end
