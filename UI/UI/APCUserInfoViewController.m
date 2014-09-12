//
//  ViewController.m
//  Profile
//
//  Created by Karthik Keyan on 8/22/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCProfile.h"
#import "NSDate+Category.h"
#import "UIView+Category.h"
#import "APCTableViewItem.h"
#import "NSString+Category.h"
#import "APCSegmentControl.h"
#import "UIScrollView+Category.h"
#import "UITableView+Appearance.h"
#import "APCUserInfoViewController.h"

static NSString * const kAPCUserInfoFieldNameRegEx              = @"[A-Za-z]+";

static CGFloat const kAPCUserInfoTableViewDefaultRowHeight      = 64.0;

@interface APCUserInfoViewController ()

@end


@implementation APCUserInfoViewController

- (void) loadView {
    self.view = [[UIView alloc] initWithFrame:UIScreen.mainScreen.bounds];
}
            
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.title = @"Profile";
    
    [self addTableView];
    [self addHeaderView];
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

- (void) addTableView {
    CGRect frame = self.view.bounds;
    
    self.tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorColor = [UITableView separatorColor];
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    self.tableView.contentInset = UIEdgeInsetsMake(self.navigationController.navigationBar.height + 10, 0, 0, 0);
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
    
    self.profileImageButton.layer.cornerRadius = self.profileImageButton.frame.size.width/2;
    
    self.firstNameTextField.font = [UITableView textFieldFont];
    self.firstNameTextField.textColor = [UITableView textFieldTextColor];
    
    self.lastNameTextField.font = [UITableView textFieldFont];
    self.lastNameTextField.textColor = [UITableView textFieldTextColor];
}


#pragma mark - UITableViewDataSource

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.fields.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    APCUserInfoCell *cell;
    
    APCTableViewItem *field = self.fields[indexPath.row];
    
    if (field) {
        cell = [tableView dequeueReusableCellWithIdentifier:field.identifier];
        if (!cell) {
            cell = [[[self cellClass] alloc] initWithStyle:field.style reuseIdentifier:field.identifier];
        }
        
        cell.selectionStyle = field.selectionStyle;
        cell.textLabel.text = field.caption;
        cell.detailTextLabel.text = field.detailText;
        cell.valueTextField.textAlignment = field.textAlignnment;
        cell.valueTextRegularExpression = field.regularExpression;
        
        
        if ([field isKindOfClass:[APCTableViewTextFieldItem class]]) {
            APCTableViewTextFieldItem *textField = (APCTableViewTextFieldItem *)field;
            
            cell.accessoryView = cell.valueTextField;
            
            cell.valueTextField.placeholder = textField.placeholder;
            cell.valueTextField.text = textField.value;
            cell.valueTextField.secureTextEntry = textField.isSecure;
            cell.valueTextField.keyboardType = textField.keyboardType;
        }
        else if ([field isKindOfClass:[APCTableViewDatePickerItem class]]) {
            APCTableViewDatePickerItem *datePickerField = (APCTableViewDatePickerItem *)field;
            
            cell.accessoryView = cell.valueTextField;
            
            cell.valueTextField.placeholder = datePickerField.placeholder;
            cell.valueTextField.text = [datePickerField.date toStringWithFormat:datePickerField.dateFormat];
            cell.valueTextField.inputView = cell.datePicker;
            
            if (datePickerField.date) {
                cell.datePicker.date = datePickerField.date;
            }
        }
        else if ([field isKindOfClass:[APCTableViewCustomPickerItem class]]) {
            APCTableViewCustomPickerItem *customPickerField = (APCTableViewCustomPickerItem *)field;
            
            [cell setCustomPickerValues:customPickerField.pickerData selectedRowIndices:customPickerField.selectedRowIndices];
            
            if (customPickerField.isDetailDiscloserStyle) {
                [cell setNeedsHiddenField];
                
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.detailTextLabel.text = customPickerField.stringValue;
                cell.valueTextField.inputView = cell.customPickerView;
            }
            else {
                cell.accessoryView = cell.valueTextField;
                cell.valueTextField.text = customPickerField.stringValue;
            }
        }
        else if ([field isKindOfClass:[APCTableViewSegmentItem class]]) {
            APCTableViewSegmentItem *segmentPickerField = (APCTableViewSegmentItem *)field;
            
            cell.accessoryView = cell.segmentControl;
            
            [cell setSegments:segmentPickerField.segments selectedIndex:segmentPickerField.selectedIndex];
        }
    }
    
    cell.delegate = self;
    
    return cell;
}


#pragma mark - UITableViewDelegate

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kAPCUserInfoTableViewDefaultRowHeight;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    APCUserInfoCell *cell = (APCUserInfoCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    APCTableViewItem *field = self.fields[indexPath.row];
    
    if ([field isKindOfClass:[APCTableViewCustomPickerItem class]] && [(APCTableViewCustomPickerItem *)field isDetailDiscloserStyle]) {
        [cell.valueTextField becomeFirstResponder];
    }
}


#pragma mark - InputCellDelegate

- (void) configurableCellDidBecomFirstResponder:(APCUserInfoCell *)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (void) configurableCell:(APCUserInfoCell *)cell textValueChanged:(NSString *)text {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    APCTableViewTextFieldItem *field = self.fields[indexPath.row];
    field.value = text;
}

- (void) configurableCell:(APCUserInfoCell *)cell switchValueChanged:(BOOL)isOn {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    APCTableViewSwitchItem *field = self.fields[indexPath.row];
    field.on = isOn;
}

- (void) configurableCell:(APCUserInfoCell *)cell segmentIndexChanged:(NSUInteger)index {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    APCTableViewSegmentItem *field = self.fields[indexPath.row];
    field.selectedIndex = index;
}

- (void) configurableCell:(APCUserInfoCell *)cell dateValueChanged:(NSDate *)date {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    APCTableViewDatePickerItem *field = self.fields[indexPath.row];
    field.date = date;
    
    cell.valueTextField.text = [field.date toStringWithFormat:field.dateFormat];
}

- (void) configurableCell:(APCUserInfoCell *)cell customPickerValueChanged:(NSArray *)selectedRowIndices {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    APCTableViewCustomPickerItem *field = self.fields[indexPath.row];
    field.selectedRowIndices = selectedRowIndices;
    
    if (field.isDetailDiscloserStyle) {
        cell.detailTextLabel.text = field.stringValue;
    }
    else {
        cell.valueTextField.text = field.stringValue;
    }
}


#pragma mark - UIImagePickerControllerDelegate

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = info[UIImagePickerControllerEditedImage];
    if (!image) {
        image = info[UIImagePickerControllerOriginalImage];
    }
    
    [self.profileImageButton setImage:image forState:UIControlStateNormal];
    
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
        isValid = [text isValidForRegex:kAPCUserInfoFieldNameRegEx];
    }
    
    return isValid;
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    return YES;
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
