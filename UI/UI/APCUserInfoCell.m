//
//  APCUserInfoCell.m
//  Configuration
//
//  Created by Karthik Keyan on 8/11/14.
//  Copyright (c) 2014 Karthik Keyan. All rights reserved.
//

#import "APCUserInfoCell.h"
#import "NSString+Category.h"
#import "UITableView+AppearanceCategory.h"

static CGFloat const kAPCUserInfoCellControlsMinHorizontalMargin    = 15.0;
static CGFloat const kAPCUserInfoCellControlsMinVerticalMargin      = 7.0;
static CGFloat const kAPCUserInfoCellTextFieldMinWidth              = 140.0;
static CGFloat const kAPCUserInfoCellControlsMinHeight              = 30.0;

@interface APCUserInfoCell () <UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, strong) CALayer *profileImageCircleLayer;

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
        self.valueTextField.textAlignment = NSTextAlignmentLeft;
        self.valueTextField.font = [UITableView textFieldFont];
        self.valueTextField.textColor = [UITableView textFieldTextColor];
    }
    
    return self;
}

#pragma mark - Custom Setter

- (void) setType:(APCUserInfoCellType)type {
    if (_type != type) {
        _type = type;
        
        switch (self.type) {
            case APCUserInfoCellTypeSingleInputText:
                [self addSingleInputText];
                break;
                
            case APCUserInfoCellTypeSwitch:
                [self addSwitch];
                break;
                
            case APCUserInfoCellTypeDatePicker:
                [self addDatePicker];
                break;
            
            case APCUserInfoCellTypeCustomPicker:
                [self addCustomPicker];
                break;
                
            case APCUserInfoCellTypeTitleValue:
                [self addTitleValue];
                break;
                
            case APCUserInfoCellTypeSegment:
                [self addSegmentControl];
                break;
            
            default:
#warning assert message require
                NSAssert(_type < APCUserInfoCellTypeSegment, NSLocalizedString(@"ASSERT_MESSAGE", @""));
                break;
        }
    }
}

- (void) setCustomPickerValues:(NSArray *)customPickerValues {
    if (customPickerValues != _customPickerValues) {
        _customPickerValues = customPickerValues;
        
        [self.customPickerView reloadAllComponents];
    }
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
    if ([self.delegate respondsToSelector:@selector(userInfoCellValueChanged:)]) {
        [self.delegate userInfoCellValueChanged:self];
    }
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    return YES;
}


#pragma mark - Private Methods

- (void) addSingleInputText {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.valueTextField.inputAccessoryView = nil;
    [self addSubview:self.valueTextField];
}

- (void) addSwitch {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (!self.switchView) {
        self.switchView = [UISwitch new];
        [self.switchView addTarget:self action:@selector(valueChanged) forControlEvents:UIControlEventValueChanged];
    }
    
    self.accessoryView = self.switchView;
}

- (void) addDatePicker {
    self.selectionStyle = UITableViewCellSelectionStyleDefault;
    
    self.valueTextField.frame = CGRectMake(0, 0, kAPCUserInfoCellTextFieldMinWidth, kAPCUserInfoCellControlsMinHeight);
    self.valueTextField.textAlignment = NSTextAlignmentRight;
    self.valueTextField.tintColor = [UIColor clearColor];
    
    self.accessoryView = self.valueTextField;
    
    {
        if (!self.datePicker) {
            self.datePicker = [[UIDatePicker alloc] init];
            self.datePicker.backgroundColor = [UIColor whiteColor];
            self.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
            [self.datePicker addTarget:self action:@selector(valueChanged) forControlEvents:UIControlEventValueChanged];
        }
        
        self.valueTextField.inputView = self.datePicker;
    }
}

- (void) addCustomPicker {
    self.selectionStyle = UITableViewCellSelectionStyleDefault;
    
    self.valueTextField.frame = CGRectMake(0, 0, kAPCUserInfoCellTextFieldMinWidth, kAPCUserInfoCellControlsMinHeight);
    self.valueTextField.textAlignment = NSTextAlignmentCenter;
    self.valueTextField.tintColor = [UIColor clearColor];
    
    self.accessoryView = self.valueTextField;
    
    [self setNeedsCustomPicker];
}

- (void) addTitleValue {
    self.selectionStyle = UITableViewCellSelectionStyleDefault;
    
    self.valueTextField.frame = CGRectMake(0, 0, kAPCUserInfoCellTextFieldMinWidth, kAPCUserInfoCellControlsMinHeight);
    self.valueTextField.textAlignment = NSTextAlignmentRight;
    self.valueTextField.tintColor = [UIColor clearColor];
    
    self.valueTextField.inputAccessoryView = nil;
    
    self.accessoryView = self.valueTextField;
}

- (void) addSegmentControl {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.textLabel.font = [UIFont systemFontOfSize:12];
    
    if (!self.segmentControl) {
        CGFloat width = self.bounds.size.width - (2 * kAPCUserInfoCellControlsMinHorizontalMargin);
        
        self.segmentControl = [[UISegmentedControl alloc] init];
        self.segmentControl.frame = CGRectMake(kAPCUserInfoCellControlsMinHorizontalMargin, 40, width, kAPCUserInfoCellControlsMinHeight);
        [self.segmentControl addTarget:self action:@selector(valueChanged) forControlEvents:UIControlEventValueChanged];
        [self addSubview:self.segmentControl];
    }
}

- (void) profileImageButtonClicked {
    if ([self.delegate respondsToSelector:@selector(userInfoCellDidSelectProfileImage:)]) {
        [self.delegate userInfoCellDidSelectProfileImage:self];
    }
}

- (void) valueChanged {
    if ([self.delegate respondsToSelector:@selector(userInfoCellValueChanged:)]) {
        [self.delegate userInfoCellValueChanged:self];
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
    NSMutableString *string = [NSMutableString string];
    
    if (pickerView.numberOfComponents == 1) {
        [string appendString:self.customPickerValues[component][row]];
    }
    else {
        for (int i = 0; i < self.customPickerValues.count; i++) {
            [string appendString:self.customPickerValues[i][[self.customPickerView selectedRowInComponent:i]]];
            
            if (i < (self.customPickerValues.count - 1)) {
                [string appendString:@" "];
            }
        }
    }
    
    self.valueTextField.text = string;
    
    if ([self.delegate respondsToSelector:@selector(userInfoCellValueChanged:)]) {
        [self.delegate userInfoCellValueChanged:self];
    }
}

- (NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.customPickerValues[component][row];
}


#pragma mark - Pubic Methods

- (void) layoutSubviews {
    [super layoutSubviews];
    
    if (self.type == APCUserInfoCellTypeSingleInputText) {
        CGFloat width = self.bounds.size.width - (2 * kAPCUserInfoCellControlsMinHorizontalMargin);
        CGFloat rectY = (self.bounds.size.height - kAPCUserInfoCellControlsMinHeight) * 0.5;
        
        self.valueTextField.frame = CGRectMake(kAPCUserInfoCellControlsMinHorizontalMargin, rectY, width, kAPCUserInfoCellControlsMinHeight);
    }
    else if (self.type == APCUserInfoCellTypeSegment) {
        [self.textLabel sizeToFit];
        
        CGFloat veticalSpace = kAPCUserInfoCellControlsMinVerticalMargin + 2;
        
        CGRect frame = self.textLabel.frame;
        frame.origin.y = veticalSpace;
        self.textLabel.frame = frame;
        
        frame = self.segmentControl.frame;
        frame.origin.y = CGRectGetMaxY(self.textLabel.frame) + veticalSpace;
        self.segmentControl.frame = frame;
    }
}

- (void) prepareForReuse {
    [super prepareForReuse];
    
    CGRect frame = CGRectMake(kAPCUserInfoCellControlsMinHorizontalMargin, kAPCUserInfoCellControlsMinVerticalMargin, kAPCUserInfoCellTextFieldMinWidth, kAPCUserInfoCellControlsMinHeight);
    
    self.valueTextField.frame = frame;
    
    self.textLabel.text = nil;
    self.detailTextLabel.text = nil;
    
    [self.segmentControl removeAllSegments];
}

- (void) setNeedsHiddenField {
    self.valueTextField.hidden = YES;
    [self addSubview:self.valueTextField];
}

- (void) setNeedsCustomPicker {
    {
        if (!self.customPickerValues) {
            self.customPickerView = [UIPickerView new];
            self.customPickerView.backgroundColor = [UIColor whiteColor];
            self.customPickerView.dataSource = self;
            self.customPickerView.delegate = self;
        }
        
        self.valueTextField.inputView = self.customPickerView;
    }
}

@end
