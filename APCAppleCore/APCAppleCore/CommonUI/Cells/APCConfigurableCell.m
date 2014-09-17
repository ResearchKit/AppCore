//
//  APCConfigurableCell.m
//  APCAppleCore
//
//  Created by Karthik Keyan on 9/11/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCSegmentControl.h"
#import "NSString+Helper.h"
#import "APCConfigurableCell.h"
#import "UITableView+Appearance.h"

static CGFloat const kAPCConfigurableCellControlsMinHorizontalMargin    = 15.0;
static CGFloat const kAPCConfigurableCellControlsMinVerticalMargin      = 7.0;
static CGFloat const kAPCConfigurableCellTextFieldMinWidth              = 186.0;
static CGFloat const kAPCConfigurableCellControlsMinHeight              = 30.0;

@interface APCConfigurableCell ()

@end


@implementation APCConfigurableCell

#pragma mark - Getter

- (UITextField *) valueTextField {
    if (!_valueTextField) {
        CGRect frame = CGRectMake(kAPCConfigurableCellControlsMinHorizontalMargin, kAPCConfigurableCellControlsMinVerticalMargin, kAPCConfigurableCellTextFieldMinWidth, kAPCConfigurableCellControlsMinHeight);
        
        _valueTextField = [UITextField new];
        _valueTextField.frame = frame;
        _valueTextField.delegate = self;
        _valueTextField.font = [UITableView textFieldFont];
        _valueTextField.textColor = [UITableView textFieldTextColor];
        _valueTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }
    
    return _valueTextField;
}

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

- (APCSegmentControl *) segmentControl {
    if (!_segmentControl) {
        _segmentControl = [APCSegmentControl new];
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


#pragma mark - UITextFieldDelegate

- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(configurableCellDidBecomFirstResponder:)]) {
        [self.delegate configurableCellDidBecomFirstResponder:self];
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
    if ([self.delegate respondsToSelector:@selector(configurableCell:dateValueChanged:)]) {
        [self.delegate configurableCell:self dateValueChanged:self.datePicker.date];
    }
}

- (void) segmentIndexChanged {
    if ([self.delegate respondsToSelector:@selector(configurableCell:segmentIndexChanged:)]) {
        [self.delegate configurableCell:self segmentIndexChanged:self.segmentControl.selectedSegmentIndex];
    }
}

- (void) switchValueChanged {
    if ([self.delegate respondsToSelector:@selector(configurableCell:switchValueChanged:)]) {
        [self.delegate configurableCell:self switchValueChanged:self.switchView.isOn];
    }
}

- (void) textValueChanged {
    if ([self.delegate respondsToSelector:@selector(configurableCell:textValueChanged:)]) {
        [self.delegate configurableCell:self textValueChanged:self.valueTextField.text];
    }
}

- (void) customPickerValueChanged {
    NSMutableArray *selectedRowIndices = [NSMutableArray array];
    
    for (int i = 0 ; i < self.customPickerValues.count; i++) {
        [selectedRowIndices addObject:@([self.customPickerView selectedRowInComponent:i])];
    }
    
    if ([self.delegate respondsToSelector:@selector(configurableCell:customPickerValueChanged:)]) {
        [self.delegate configurableCell:self customPickerValueChanged:selectedRowIndices];
    }
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

@end
