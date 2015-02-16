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
#import "APCPermissionsManager.h"

#import "APCParameters+Settings.h"

static CGFloat const kSectionHeaderHeight = 40.f;
static CGFloat const kStudyDetailsViewHeightConstant = 48.f;
static CGFloat const kPickerCellHeight = 164.0f;

static NSString * const kAPCBasicTableViewCellIdentifier = @"APCBasicTableViewCell";
static NSString * const kAPCRightDetailTableViewCellIdentifier = @"APCRightDetailTableViewCell";

@interface APCProfileViewController ()

@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@property (nonatomic, strong) APCParameters *parameters;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *studyDetailsViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *studyLabelCenterYConstraint;
@property (strong, nonatomic) APCPermissionsManager *permissionManager;

@end

@implementation APCProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    CGRect headerRect = self.headerView.frame;
    headerRect.size.height = 159.0f;
    self.headerView.frame = headerRect;
    
    self.tableView.tableHeaderView = self.tableView.tableHeaderView;
  APCLogViewControllerAppeared();
    
    
    [self setupAppearance];
    
    self.nameTextField.delegate = self;
    
    [self.profileImageButton.imageView setContentMode:UIViewContentModeScaleAspectFill];
    
    self.items = [self prepareContent];
    [self.tableView reloadData];
    
    self.nameTextField.text = self.user.name;
    self.nameTextField.enabled = NO;
    
    self.emailTextField.text = self.user.email;
    self.emailTextField.enabled = NO;
    
    self.profileImage = [UIImage imageWithData:self.user.profileImage];
    if (self.profileImage) {
        [self.profileImageButton setImage:self.profileImage forState:UIControlStateNormal];
    } else {
        [self.profileImageButton setImage:[UIImage imageNamed:@"profilePlaceholder"] forState:UIControlStateNormal];
    }
    
    self.permissionManager = [[APCPermissionsManager alloc] init];
    
    [self setupDataFromJSONFile:@"StudyOverview"];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger count = self.items.count;
    
    NSInteger profileExtenderSections = 0;
    
    if ([self.delegate respondsToSelector:@selector(numberOfSectionsInTableView:)] && count != 0)
    {
        profileExtenderSections = [self.delegate numberOfSectionsInTableView:tableView];
    }
    
    if (profileExtenderSections > 0) {
        count += profileExtenderSections;
    }
    
    return count;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    NSInteger count = 0;
    
    if ( section >= self.items.count )
    {
        
        if ([self.delegate respondsToSelector:@selector(tableView:numberOfRowsInAdjustedSection:)])
        {
            NSInteger adjustedSectionForExtender = section - self.items.count;
            
            count = [self.delegate tableView:tableView numberOfRowsInAdjustedSection:adjustedSectionForExtender];
        }
        
    }
    else
    {

        APCTableViewSection *itemsSection = self.items[section];
        
        count = itemsSection.rows.count;
        
        if (self.isPickerShowing && self.pickerIndexPath.section == section)
        {
            count ++;
        }
    }
    
    return count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if (indexPath.section >= self.items.count) {
        
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"APCDefaultTableViewCell"];
        }
        
        UIView *view = nil;
        if ([self.delegate respondsToSelector:@selector(cellForRowAtAdjustedIndexPath:)])
        {
            NSInteger adjustedSectionForExtender = indexPath.section - self.items.count;
            
            NSIndexPath *newIndex = [NSIndexPath indexPathForRow:indexPath.row inSection:adjustedSectionForExtender];
            
            view = [self.delegate cellForRowAtAdjustedIndexPath:newIndex];
        }
    
        if (view) {
            [cell.contentView addSubview:view];
        }
        
    } else {
        
        if (self.pickerIndexPath && [self.pickerIndexPath isEqual:indexPath]) {
            cell = [tableView dequeueReusableCellWithIdentifier:kAPCPickerTableViewCellIdentifier];
            
            NSIndexPath *actualIndexPath = [NSIndexPath indexPathForRow:(indexPath.row - 1) inSection:indexPath.section];
            APCTableViewItem *field = [self itemForIndexPath:actualIndexPath];
            
            APCPickerTableViewCell *pickerCell = (APCPickerTableViewCell *)cell;
            
            if ([field isKindOfClass:[APCTableViewDatePickerItem class]]) {
                
                APCTableViewDatePickerItem *datePickerField = (APCTableViewDatePickerItem *)field;
                
                pickerCell.type = kAPCPickerCellTypeDate;
                if (datePickerField.date) {
                    pickerCell.datePicker.date = datePickerField.date;
                }
                
                pickerCell.datePicker.datePickerMode = datePickerField.datePickerMode;
                if (datePickerField.minimumDate) {
                    pickerCell.datePicker.minimumDate = datePickerField.minimumDate;
                }
                if (datePickerField.maximumDate) {
                    pickerCell.datePicker.maximumDate = datePickerField.maximumDate;
                }
                pickerCell.delegate = self;
                
                [self setupPickerCellAppeareance:pickerCell];
                
            } else if ([field isKindOfClass:[APCTableViewCustomPickerItem class]]){
                
                APCTableViewCustomPickerItem *customPickerField = (APCTableViewCustomPickerItem *)field;
                pickerCell.type = kAPCPickerCellTypeCustom;
                pickerCell.pickerValues = customPickerField.pickerData;
                [pickerCell.pickerView reloadAllComponents];
                pickerCell.delegate = self;
                pickerCell.selectedRowIndices = customPickerField.selectedRowIndices;
                
                [self setupPickerCellAppeareance:pickerCell];
            }
            
        } else {
            
            APCTableViewItem *field = [self itemForIndexPath:indexPath];
            
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
                    textFieldCell.textField.text = textFieldItem.value;
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
                    
                    if (datePickerField.date) {
                        NSString *dateWithFormat = [datePickerField.date toStringWithFormat:datePickerField.dateFormat];
                        defaultCell.detailTextLabel.text = dateWithFormat;
                        defaultCell.detailTextLabel.textColor = [UIColor appSecondaryColor1];
                    } else {
                        defaultCell.detailTextLabel.text = field.placeholder;
                        defaultCell.detailTextLabel.textColor = [UIColor appSecondaryColor3];
                    }
                    
#warning temporarily disabled this code to make tableview work
//                    if (field.textAlignnment == NSTextAlignmentRight) {
//                        defaultCell.type = kAPCDefaultTableViewCellTypeRight;
//                    } else {
//                        defaultCell.type = kAPCDefaultTableViewCellTypeLeft;
//                    }
                    
                    [self setupDefaultCellAppearance:defaultCell];
                    
                }
                else if ([field isKindOfClass:[APCTableViewCustomPickerItem class]]) {
                    
                    APCTableViewCustomPickerItem *customPickerField = (APCTableViewCustomPickerItem *)field;
                    APCDefaultTableViewCell *defaultCell = (APCDefaultTableViewCell *)cell;
                    
                    defaultCell.detailTextLabel.text = customPickerField.stringValue;

#warning temporarily disabled this code to make tableview work
//                    if (field.textAlignnment == NSTextAlignmentRight) {
//                        defaultCell.type = kAPCDefaultTableViewCellTypeRight;
//                    } else {
//                        defaultCell.type = kAPCDefaultTableViewCellTypeLeft;
//                    }
                    
                    [self setupDefaultCellAppearance:defaultCell];
                    
                } else if ([field isKindOfClass:[APCTableViewSegmentItem class]]) {
                    
                    APCTableViewSegmentItem *segmentPickerField = (APCTableViewSegmentItem *)field;
                    APCSegmentedTableViewCell *segmentedCell = (APCSegmentedTableViewCell *)cell;
                    segmentedCell.delegate = self;
                    segmentedCell.selectedSegmentIndex = segmentPickerField.selectedIndex;
                    segmentedCell.userInteractionEnabled = segmentPickerField.editable;
                    
                } else if ([field isKindOfClass:[APCTableViewSwitchItem class]]) {
                    
                    APCTableViewSwitchItem *switchField = (APCTableViewSwitchItem *)field;
                    APCSwitchTableViewCell *switchCell = (APCSwitchTableViewCell *)cell;
                    switchCell.textLabel.text = switchField.caption;
                    switchCell.cellSwitch.on = switchField.on;
                    switchCell.delegate = self;
                    
                    [self setupSwitchCellAppearance:switchCell];
                } else {
                    if (!cell) {
                        cell = [[UITableViewCell alloc] initWithStyle:field.style reuseIdentifier:field.identifier];
                    }
                    [self setupBasicCellAppearance:cell];
                }
                
                if (self.isEditing && field.editable && !self.signUp) {
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.selectionStyle = UITableViewCellSelectionStyleGray;
                } else{
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
            }
        }
    }


    return cell;
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
                    
                case kAPCUserInfoItemTypeCustomSurvey:
                {
                    APCTableViewTextFieldItem *field = [APCTableViewTextFieldItem new];
                    field.textAlignnment = NSTextAlignmentLeft;
                    field.placeholder = NSLocalizedString(@"custom question", @"");
                    field.caption = @"Daily Scale";
                    if (self.user.customSurveyQuestion) {
                        field.value = self.user.customSurveyQuestion;
                    }
                    field.keyboardType = UIKeyboardTypeAlphabet;
                    field.identifier = kAPCTextFieldTableViewCellIdentifier;
                    
                    field.style = UITableViewStylePlain;
                    
                    APCTableViewRow *row = [APCTableViewRow new];
                    row.item = field;
                    row.itemType = kAPCUserInfoItemTypeCustomSurvey;
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
#warning this needs a solution. This causes a crash.
                    
                    NSInteger defaultIndexOfMyHeightInFeet = 5;
                    NSInteger defaultIndexOfMyHeightInInches = 0;
                    NSInteger indexOfMyHeightInFeet = defaultIndexOfMyHeightInFeet;
                    NSInteger indexOfMyHeightInInches = defaultIndexOfMyHeightInInches;
                    
                    if (self.user.height) {
                        
                        double heightInInches = roundf([APCUser heightInInches:self.user.height]);
                        NSString *feet = [NSString stringWithFormat:@"%d'", (int)heightInInches/12];
                        NSString *inches = [NSString stringWithFormat:@"%d''", (int)heightInInches%12];
                        
                        NSArray *allPossibleHeightsInFeet = field.pickerData [0];
                        NSArray *allPossibleHeightsInInches = field.pickerData [1];
                        
                        indexOfMyHeightInFeet = [allPossibleHeightsInFeet indexOfObject: feet];
                        indexOfMyHeightInInches = [allPossibleHeightsInInches indexOfObject: inches];
                        
                        if (indexOfMyHeightInFeet == NSNotFound)
                        {
                            indexOfMyHeightInFeet = defaultIndexOfMyHeightInFeet;
                        }
                        
                        if (indexOfMyHeightInInches == NSNotFound)
                        {
                            indexOfMyHeightInInches = defaultIndexOfMyHeightInInches;
                        }
                        
                        field.selectedRowIndices = @[ @(indexOfMyHeightInFeet), @(indexOfMyHeightInInches) ];

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
                    field.caption = NSLocalizedString(@"What time do you generally wake up?", @"");
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
                    field.caption = NSLocalizedString(@"What time do you generally go to sleep?", @"");
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
    
    
     {
     NSMutableArray *rowItems = [NSMutableArray new];
     
     {
     APCTableViewItem *field = [APCTableViewItem new];
     field.caption = NSLocalizedString(@"Activity Reminders", @"");
     field.identifier = kAPCDefaultTableViewCellIdentifier;
     field.editable = NO;
     
     APCTableViewRow *row = [APCTableViewRow new];
     row.item = field;
     row.itemType = kAPCSettingsItemTypeReminderOnOff;
     [rowItems addObject:row];
     }

//     {
//     APCTableViewCustomPickerItem *field = [APCTableViewCustomPickerItem new];
//     field.caption = NSLocalizedString(@"Reminder Time", @"");
//     field.pickerData = @[[APCTasksReminderManager reminderTimesArray]];
//     field.textAlignnment = NSTextAlignmentRight;
//     field.identifier = kAPCDefaultTableViewCellIdentifier;
//     APCAppDelegate * appDelegate = (APCAppDelegate*) [UIApplication sharedApplication].delegate;
//     field.selectedRowIndices = @[@([[APCTasksReminderManager reminderTimesArray] indexOfObject:appDelegate.tasksReminder.reminderTime])];
//     
//     APCTableViewRow *row = [APCTableViewRow new];
//     row.item = field;
//     row.itemType = kAPCSettingsItemTypeReminderTime;
//     [rowItems addObject:row];
//     }
     

     APCTableViewSection *section = [APCTableViewSection new];

     section.rows = [NSArray arrayWithArray:rowItems];
     [items addObject:section];
     }


    
    {
        NSMutableArray *rowItems = [NSMutableArray new];
        
        {
            APCTableViewCustomPickerItem *field = [APCTableViewCustomPickerItem new];
            field.identifier = kAPCDefaultTableViewCellIdentifier;
            field.selectionStyle = UITableViewCellSelectionStyleGray;
            field.caption = NSLocalizedString(@"Auto-Lock", @"");
            field.detailDiscloserStyle = YES;
            field.textAlignnment = NSTextAlignmentRight;
            field.pickerData = @[[APCParameters autoLockOptionStrings]];

#warning This may be just a temporary fix
            
            NSNumber *numberOfMinutes = [self.parameters numberForKey:kNumberOfMinutesForPasscodeKey];
            
            if ( numberOfMinutes != nil)
            {
                NSInteger index = [[APCParameters autoLockValues] indexOfObject:numberOfMinutes];
                field.selectedRowIndices = @[@(index)];
            }

            APCTableViewRow *row = [APCTableViewRow new];
            row.item = field;
            row.itemType = kAPCSettingsItemTypeAutoLock;
            [rowItems addObject:row];
        }
        
        {
            APCTableViewItem *field = [APCTableViewItem new];
            field.caption = NSLocalizedString(@"Change Passcode", @"");
            field.identifier = kAPCBasicTableViewCellIdentifier;
            field.textAlignnment = NSTextAlignmentRight;
            field.editable = NO;
            
            APCTableViewRow *row = [APCTableViewRow new];
            row.item = field;
            row.itemType = kAPCSettingsItemTypePasscode;
            [rowItems addObject:row];
        }
        
        APCTableViewSection *section = [APCTableViewSection new];
        section.rows = [NSArray arrayWithArray:rowItems];
        section.sectionTitle = @"Security";
        [items addObject:section];
    }

    {
        NSMutableArray *rowItems = [NSMutableArray new];
        
        {
            APCTableViewItem *field = [APCTableViewItem new];
            field.caption = NSLocalizedString(@"Permissions", @"");
            field.identifier = kAPCDefaultTableViewCellIdentifier;
            field.textAlignnment = NSTextAlignmentRight;
            field.editable = NO;
            
            APCTableViewRow *row = [APCTableViewRow new];
            row.item = field;
            row.itemType = kAPCSettingsItemTypePermissions;
            [rowItems addObject:row];
        }
        
        {
            APCTableViewItem *field = [APCTableViewItem new];
            field.caption = NSLocalizedString(@"Review Consent", @"");
            field.identifier = kAPCDefaultTableViewCellIdentifier;
            field.textAlignnment = NSTextAlignmentRight;
            field.editable = NO;
            
            APCTableViewRow *row = [APCTableViewRow new];
            row.item = field;
            row.itemType = kAPCUserInfoItemTypeReviewConsent;
            [rowItems addObject:row];
        }
        
        APCTableViewSection *section = [APCTableViewSection new];
        section.rows = [NSArray arrayWithArray:rowItems];
        section.sectionTitle = @"";
        [items addObject:section];
    }

    NSArray *newArray = nil;
    if ([self.delegate respondsToSelector:@selector(preparedContent:)])
    {
        newArray = [self.delegate preparedContent:[NSArray arrayWithArray:items]];
    }
    
    return newArray ? newArray : [NSArray arrayWithArray:items];
}

- (void)setupSwitchCellAppearance:(APCSwitchTableViewCell *)cell
{
    [cell.textLabel setFont:[UIFont appRegularFontWithSize:14.0f]];
    [cell.textLabel setTextColor:[UIColor appSecondaryColor1]];
}

/*********************************************************************************/
#pragma mark - Switch Cell Delegate
/*********************************************************************************/

- (void)switchTableViewCell:(APCSwitchTableViewCell *)cell switchValueChanged:(BOOL)on
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if (indexPath.section == 1 && indexPath.row == 0) {
        APCAppDelegate * appDelegate = (APCAppDelegate*) [UIApplication sharedApplication].delegate;
        appDelegate.tasksReminder.reminderOn = on;
    }
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
    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    
    [self.nameTextField setTextColor:[UIColor appSecondaryColor1]];
    [self.nameTextField setFont:[UIFont appRegularFontWithSize:16.0f]];
    
    [self.emailTextField setTextColor:[UIColor appSecondaryColor1]];
    [self.emailTextField setFont:[UIFont appRegularFontWithSize:16.0f]];
    
    [self.profileImageButton.imageView.layer setCornerRadius:CGRectGetHeight(self.profileImageButton.bounds)/2];
    
    [self.editLabel setTextColor:[UIColor appSecondaryColor1]];
    [self.editLabel setFont:[UIFont appRegularFontWithSize:14.0f]];
    
    [self.footerTitleLabel setTextColor:[UIColor appSecondaryColor1]];
    [self.footerTitleLabel setFont:[UIFont appLightFontWithSize:16.0f]];
    
    [self.editLabel setTextColor:[UIColor appSecondaryColor1]];
    [self.editLabel setFont:[UIFont appRegularFontWithSize:14.0f]];
    
    [self.editLabel setTextColor:[UIColor appSecondaryColor1]];
    [self.editLabel setFont:[UIFont appRegularFontWithSize:14.0f]];
    
    [self.diseaseLabel setTextColor:[UIColor appSecondaryColor1]];
    [self.diseaseLabel setFont:[UIFont appRegularFontWithSize:16.0f]];
    
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = tableView.rowHeight;
    
    if (indexPath.section >= self.items.count) {
        

        
        if ([self.delegate respondsToSelector:@selector(tableView:heightForRowAtAdjustedIndexPath:)])
        {
            NSInteger adjustedSectionForExtender = indexPath.section - self.items.count;
            NSIndexPath *newIndex = [NSIndexPath indexPathForRow:indexPath.row inSection:adjustedSectionForExtender];
            height = [self.delegate tableView:tableView heightForRowAtAdjustedIndexPath:newIndex];
        }
    } else {
        
        if (self.isPickerShowing && [indexPath isEqual:self.pickerIndexPath]) {
            height = kPickerCellHeight;
        }
    }

    
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    if (indexPath.section >= self.items.count) {
        
        if ([self.delegate respondsToSelector:@selector(navigationController:didSelectRowAtIndexPath:)])
        {

            NSInteger adjustedSectionForExtender = indexPath.section - self.items.count;
            NSIndexPath *newIndex = [NSIndexPath indexPathForRow:indexPath.row inSection:adjustedSectionForExtender];
            [self.delegate navigationController:self.navigationController didSelectRowAtIndexPath:newIndex];
        }
    } else {
        
        APCTableViewItemType type = [self itemTypeForIndexPath:indexPath];
        
        switch (type) {
            case kAPCTableViewStudyItemTypeShare:
            {
                //            APCShareViewController *shareViewController = [[UIStoryboard storyboardWithName:@"APCOnboarding" bundle:[NSBundle appleCoreBundle]] instantiateViewControllerWithIdentifier:@"APCShareViewController"];
                //            shareViewController.hidesOkayButton = YES;
                //            [self.navigationController pushViewController:shareViewController animated:YES];
            }
                break;
                
            case kAPCSettingsItemTypePasscode:
            {
                APCChangePasscodeViewController *changePasscodeViewController = [[UIStoryboard storyboardWithName:@"APCProfile" bundle:[NSBundle appleCoreBundle]] instantiateViewControllerWithIdentifier:@"ChangePasscodeVC"];
                [self.navigationController presentViewController:changePasscodeViewController animated:YES completion:nil];
            }
                break;
            case kAPCSettingsItemTypePermissions:
            {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            }
                break;
            case kAPCUserInfoItemTypeReviewConsent:

                break;
                
            case kAPCSettingsItemTypeReminderOnOff:
            {
                
                
                APCSettingsViewController *remindersTableViewController = [[UIStoryboard storyboardWithName:@"APCProfile" bundle:[NSBundle appleCoreBundle]] instantiateViewControllerWithIdentifier:@"APCSettingsViewController"];
                
                [self.navigationController pushViewController:remindersTableViewController animated:YES];
                
            }
                break;
                
            default:{
                [super tableView:tableView didSelectRowAtIndexPath:indexPath];
            }
                break;
        }
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
    
    if ( section >= self.items.count )
    {
        
        if ([self.delegate respondsToSelector:@selector(tableView:numberOfRowsInSection:)])
        {
            headerView = [[UITableViewHeaderFooterView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.frame), kSectionHeaderHeight)];
            headerView.contentView.backgroundColor = [UIColor appSecondaryColor4];
        }
        
    }
    else
    {
        
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
    }
    
    return headerView;
}

#pragma mark - UITextFieldDelegate methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (textField == self.nameTextField) {
        self.user.name = text;
    }
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == self.nameTextField) {
        self.user.name = textField.text;
    }
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    
    if ((textField == self.nameTextField) && self.emailTextField) {
        [self nextResponderForIndexPath:nil];
    }
    
    return YES;
}

#pragma mark - APCPickerTableViewCellDelegate methods

- (void)pickerTableViewCell:(APCPickerTableViewCell *)cell pickerViewDidSelectIndices:(NSArray *)selectedIndices
{
    [super pickerTableViewCell:cell pickerViewDidSelectIndices:selectedIndices];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if (indexPath.section == 0 && indexPath.row == 1) {
        NSInteger index = ((NSNumber *)selectedIndices[0]).integerValue;
        [self.parameters setNumber:[APCParameters autoLockValues][index] forKey:kNumberOfMinutesForPasscodeKey];
    }
    else if (indexPath.section == 1 && indexPath.row == 2) {
        APCAppDelegate * appDelegate = (APCAppDelegate*) [UIApplication sharedApplication].delegate;
        NSInteger index = ((NSNumber *)selectedIndices[0]).integerValue;
        appDelegate.tasksReminder.reminderTime = [APCTasksReminderManager reminderTimesArray][index];
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
    self.user.profileImage = UIImagePNGRepresentation(image);
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Public methods

- (void)loadProfileValuesInModel
{
    self.user.name = self.nameTextField.text;
    
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
                case kAPCUserInfoItemTypeCustomSurvey:
                    
                {
                    NSLog(@"%@",[(APCTableViewTextFieldItem *)item value]);
                    
                    if ([(APCTableViewTextFieldItem *)item value] != nil && ![[(APCTableViewTextFieldItem *)item value] isEqualToString:@""]) {
                        
                        self.user.customSurveyQuestion = [(APCTableViewTextFieldItem *)item value];
                    }
                }
                    break;
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
                    
                case kAPCSettingsItemTypeAutoLock:

                    break;

                case kAPCSettingsItemTypePasscode:

                    break;
                    
                case kAPCSettingsItemTypeReminderOnOff:

                    break;
                    
                case kAPCSettingsItemTypeReminderTime:

                    break;
                    
                case kAPCSettingsItemTypePermissions:

                    break;
                    
                case kAPCUserInfoItemTypeReviewConsent:
                    
                    break;
                default:
                    NSAssert(itemType <= kAPCUserInfoItemTypeWakeUpTime, @"ASSERT_MESSAGE");
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
        
        self.studyDetailsViewHeightConstraint.constant = kStudyDetailsViewHeightConstant;
        self.studyLabelCenterYConstraint.constant = 0.f;
        [self.tableView layoutIfNeeded];
    }
}

- (void)logOut
{
    APCSpinnerViewController *spinnerController = [[APCSpinnerViewController alloc] init];
    [self presentViewController:spinnerController animated:YES completion:nil];
    
    typeof(self) __weak weakSelf = self;
    
    [self.user signOutOnCompletion:^(NSError *error) {
        if (error) {
            APCLogError2 (error);
            [spinnerController dismissViewControllerAnimated:NO completion:^{
                UIAlertController *alert = [UIAlertController simpleAlertWithTitle:NSLocalizedString(@"Sign Out", @"") message:error.message];
                [weakSelf presentViewController:alert animated:YES completion:nil];
            }];
        } else {
            [spinnerController dismissViewControllerAnimated:NO completion:^{
                [[NSNotificationCenter defaultCenter] postNotificationName:APCUserLogOutNotification object:self];
            }];
        }
    }];
    
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

//- (IBAction)showSettings:(id)sender
//{
//    APCSettingsViewController *settingsViewController = [[UIStoryboard storyboardWithName:@"APCProfile" bundle:[NSBundle appleCoreBundle]] instantiateViewControllerWithIdentifier:@"APCSettingsViewController"];
//    [self.navigationController pushViewController:settingsViewController animated:YES];
//}

- (IBAction)signOut:(id)sender
{
    UIAlertController *alertContorller = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Sign Out", @"") message:NSLocalizedString(@"Are you sure you want to sign out?", nil) preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *signOutAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Sign Out", @"") style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [self logOut];
    }];
    [alertContorller addAction:signOutAction];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
       
    }];
    [alertContorller addAction:cancelAction];
    
    [self.navigationController presentViewController:alertContorller animated:YES completion:nil];
    
}

- (IBAction)leaveStudy:(id)sender
{
    UIAlertController *alertContorller = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Withdraw", @"") message:NSLocalizedString(@"Are you sure you want to withdraw from the study?\nThis action cannot be undone.", nil) preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *withdrawAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Withdraw", @"") style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [self withdraw];
    }];
    [alertContorller addAction:withdrawAction];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];
    [alertContorller addAction:cancelAction];
    
    [self.navigationController presentViewController:alertContorller animated:YES completion:nil];
}

- (IBAction)changeProfileImage:(id)sender
{
    if (self.isEditing) {
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
    
    self.nameTextField.enabled = self.isEditing;
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
