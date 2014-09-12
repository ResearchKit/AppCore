//
//  APCUserInfoCell.m
//  Configuration
//
//  Created by Karthik Keyan on 8/11/14.
//  Copyright (c) 2014 Karthik Keyan. All rights reserved.
//

#import "APCUserInfoCell.h"
#import "UIView+Category.h"
#import "APCSegmentControl.h"
#import "NSString+Category.h"
#import "UITableView+Appearance.h"

static CGFloat const kAPCUserInfoCellControlsMinHorizontalMargin    = 15.0;
static CGFloat const kAPCUserInfoCellControlsMinVerticalMargin      = 7.0;
static CGFloat const kAPCUserInfoCellTextFieldMinWidth              = 186.0;
static CGFloat const kAPCUserInfoCellControlsMinHeight              = 30.0;

@interface APCUserInfoCell () <UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, strong) CALayer *profileImageCircleLayer;

@property (nonatomic, strong) NSArray *customPickerValues;

@end

@implementation APCUserInfoCell

- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.font = [UITableView textLabelFont];
        self.textLabel.textColor = [UITableView textLabelTextColor];
        
        self.detailTextLabel.font = [UITableView detailLabelFont];
        self.detailTextLabel.textColor = [UITableView detailLabelTextColor];
        
        CGRect frame = CGRectMake(kAPCUserInfoCellControlsMinHorizontalMargin, kAPCUserInfoCellControlsMinVerticalMargin, kAPCUserInfoCellTextFieldMinWidth, kAPCUserInfoCellControlsMinHeight);
        
        self.valueTextField = [[UITextField alloc] initWithFrame:frame];
        self.valueTextField.delegate = self;
        self.valueTextField.font = [UITableView textFieldFont];
        self.valueTextField.textColor = [UITableView textFieldTextColor];
    }
    
    return self;
}


#pragma mark - Getter 

- (UIPickerView *) customPickerView {
    if (!_customPickerView) {
        _customPickerView = [UIPickerView new];
        _customPickerView.backgroundColor = [UIColor whiteColor];
        _customPickerView.dataSource = self;
        _customPickerView.delegate = self;
    }
    
    return _customPickerView;
}

- (UIDatePicker *) datePicker {
    if (!_datePicker) {
        _datePicker = [UIDatePicker new];
        _datePicker.backgroundColor = [UIColor whiteColor];
        _datePicker.datePickerMode = UIDatePickerModeDateAndTime;
        [_datePicker addTarget:self action:@selector(datePickerValueChanged) forControlEvents:UIControlEventValueChanged];
    }
    
    return _datePicker;
}

- (UISegmentedControl *) segmentControl {
    if (!_segmentControl) {
        CGFloat width = self.innerWidth - (2 * kAPCUserInfoCellControlsMinHorizontalMargin);
        
        _segmentControl = [APCSegmentControl new];
        _segmentControl.frame = CGRectMake(kAPCUserInfoCellControlsMinHorizontalMargin, 0, width, kAPCUserInfoCellControlsMinHeight);
        [_segmentControl addTarget:self action:@selector(segmentIndexChanged) forControlEvents:UIControlEventValueChanged];
    }
    
    return _segmentControl;
}

- (UISwitch *) switchView {
    if (!_switchView) {
        _switchView = [UISwitch new];
        [_switchView addTarget:self action:@selector(switchValueChanged) forControlEvents:UIControlEventValueChanged];
    }
    
    return _switchView;
}


#pragma mark - UITextFieldDelegate

- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(userInfoCellDidBecomFirstResponder:)]) {
        [self.delegate userInfoCellDidBecomFirstResponder:self];
    }
    
    return YES;
}

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    BOOL isValid = NO;
    
    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (text.length > 0 && self.valueTextRegularExpression) {
        isValid = [text isValidForRegex:self.valueTextRegularExpression];
    }
    else {
        isValid = YES;
    }
    
    return isValid;
}

- (void) textFieldDidEndEditing:(UITextField *)textField {
    // If the textfeld has any input view other than keyboard,
    // then the input pull have to respond to value change
    if (!textField.inputView) {
        [self textValueChanged];
    }
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    return YES;
}


#pragma mark - Private Methods

- (void) datePickerValueChanged {
    if ([self.delegate respondsToSelector:@selector(userInfoCell:dateValueChanged:)]) {
        [self.delegate userInfoCell:self dateValueChanged:self.datePicker.date];
    }
}

- (void) segmentIndexChanged {
    if ([self.delegate respondsToSelector:@selector(userInfoCell:segmentIndexChanged:)]) {
        [self.delegate userInfoCell:self segmentIndexChanged:self.segmentControl.selectedSegmentIndex];
    }
}

- (void) switchValueChanged {
    if ([self.delegate respondsToSelector:@selector(userInfoCell:switchValueChanged:)]) {
        [self.delegate userInfoCell:self switchValueChanged:self.switchView.isOn];
    }
}

- (void) textValueChanged {
    if ([self.delegate respondsToSelector:@selector(userInfoCell:textValueChanged:)]) {
        [self.delegate userInfoCell:self textValueChanged:self.valueTextField.text];
    }
}

- (void) customPickerValueChanged {
    NSMutableArray *selectedRowIndices = [NSMutableArray array];
    
    for (int i = 0 ; i < self.customPickerValues.count; i++) {
        [selectedRowIndices addObject:@([self.customPickerView selectedRowInComponent:i])];
    }
    
    if ([self.delegate respondsToSelector:@selector(userInfoCell:customPickerValueChanged:)]) {
        [self.delegate userInfoCell:self customPickerValueChanged:selectedRowIndices];
    }
}


#pragma mark - UIPickerViewDataSource

- (NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return self.customPickerValues.count;
}

- (NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.customPickerValues[component] count];
}


#pragma mark - UIPickerViewDelegate

- (void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [self customPickerValueChanged];
}

- (NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.customPickerValues[component][row];
}


#pragma mark - Super Class Methods

- (void) prepareForReuse {
    [super prepareForReuse];
    
    CGRect frame = CGRectMake(kAPCUserInfoCellControlsMinHorizontalMargin, kAPCUserInfoCellControlsMinVerticalMargin, kAPCUserInfoCellTextFieldMinWidth, kAPCUserInfoCellControlsMinHeight);
    
    self.valueTextField.frame = frame;
    
    self.textLabel.text = nil;
    self.detailTextLabel.text = nil;
    
    [self.segmentControl removeAllSegments];
}


#pragma mark - Pubic Methods

- (void) setSegments:(NSArray *)segments selectedIndex:(NSUInteger)selectedIndex {
    [self.segmentControl removeAllSegments];
    
    for (int i = 0; i < segments.count; i++) {
        [self.segmentControl insertSegmentWithTitle:segments[i] atIndex:i animated:NO];
    }
    
    [self.segmentControl setSelectedSegmentIndex:selectedIndex];
}

- (void) setCustomPickerValues:(NSArray *)customPickerValues selectedRowIndices:(NSArray *)selectedRowIndices {
    if (customPickerValues != _customPickerValues) {
        _customPickerValues = customPickerValues;
        
        [self.customPickerView reloadAllComponents];
        
        for (int i = 0 ; i < selectedRowIndices.count; i++) {
            [self.customPickerView selectRow:[selectedRowIndices[i] integerValue] inComponent:i animated:NO];
        }
    }
}


- (void) setNeedsHiddenField {
    self.valueTextField.hidden = YES;
    [self addSubview:self.valueTextField];
}

@end
