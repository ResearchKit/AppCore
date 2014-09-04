//
//  APCUserInfoCell.m
//  Configuration
//
//  Created by Karthik Keyan on 8/11/14.
//  Copyright (c) 2014 Karthik Keyan. All rights reserved.
//

#import "APCUserInfoCell.h"
#import "NSString+Category.h"

@interface APCUserInfoCell () <UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, strong) CALayer *separatorLayer;
@property (nonatomic, strong) CALayer *profileImageCircleLayer;

@end

@implementation APCUserInfoCell

- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier type:(APCUserInfoCellType)type {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.font = [UIFont systemFontOfSize:15];
        
        _valueTextField = [[UITextField alloc] initWithFrame:CGRectMake(15, 7, 140, 30)];
        _valueTextField.delegate = self;
        _valueTextField.textAlignment = NSTextAlignmentLeft;
        _valueTextField.font = [UIFont systemFontOfSize:15];
        
        _separatorLayer = [CALayer layer];
        _separatorLayer.frame = CGRectMake(15, self.bounds.size.height - 1, self.bounds.size.width - 15, 0.5);
        _separatorLayer.borderWidth = 1.0;
        _separatorLayer.borderColor = [UIColor colorWithWhite:0.5 alpha:0.6].CGColor;
        [self.layer addSublayer:_separatorLayer];
        
        [self setType:type];
    }
    
    return self;
}

#pragma mark - Custom Setter

- (void) setType:(APCUserInfoCellType)type {
    if (_type != type) {
        _type = type;
        
        switch (self.type) {
            case APCUserInfoCellTypeImageText:
                [self addImageText];
                break;
                
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
                break;
        }
    }
}


#pragma mark - UITextFieldDelegate

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    BOOL isValid = YES;
    
    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (text.length > 0 && self.valueTextRegularExpression) {
        isValid = [text isValidForRegex:self.valueTextRegularExpression];
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

- (void) addImageText {
//    self.backgroundColor = [UIColor greenColor];
    
    self.valueTextField.inputAccessoryView = nil;
    [self addSubview:_valueTextField];
    
    self.profileImageCircleLayer = [CALayer layer];
    self.profileImageCircleLayer.cornerRadius = 35;
    self.profileImageCircleLayer.borderColor = [UIColor colorWithWhite:0.5 alpha:0.6].CGColor;
    self.profileImageCircleLayer.borderWidth = 1.0;
    [self.layer addSublayer:self.profileImageCircleLayer];
    
    self.profileImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.profileImageButton.titleLabel.numberOfLines = 2;
    self.profileImageButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.profileImageButton setTitle:@"add\nphoto" forState:UIControlStateNormal];
    [self.profileImageButton addTarget:self action:@selector(profileImageButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.profileImageButton];
}

- (void) addSingleInputText {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.valueTextField.frame = CGRectMake(15, (self.bounds.size.height - 30) * 0.5, 300, 30);
    self.valueTextField.inputAccessoryView = nil;
    [self addSubview:_valueTextField];
}

- (void) addSwitch {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (!self.switchView) {
        self.switchView = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 70, 30)];
        [self.switchView addTarget:self action:@selector(switchValueChanged) forControlEvents:UIControlEventValueChanged];
    }
    
    self.accessoryView = self.switchView;
}

- (void) addDatePicker {
    self.selectionStyle = UITableViewCellSelectionStyleDefault;
    
    _valueTextField.frame = CGRectMake(0, 0, 100, 30);
    _valueTextField.font = [UIFont systemFontOfSize:14];
    _valueTextField.textColor = [UIColor grayColor];
    _valueTextField.textAlignment = NSTextAlignmentRight;
    _valueTextField.tintColor = [UIColor clearColor];
    
    self.accessoryView = self.valueTextField;
    
    {
        if (!self.datePicker) {
            self.datePicker = [[UIDatePicker alloc] init];
            self.datePicker.backgroundColor = [UIColor whiteColor];
            self.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
        }
        
        self.valueTextField.inputView = self.datePicker;
    }
    
    {
        UIBarButtonItem *extraSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *accept = [[UIBarButtonItem alloc] initWithTitle:@"Select" style:UIBarButtonItemStyleDone target:self action:@selector(datePickerValueChanged)];
        
        UIToolbar *keyboardToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 44)];
        keyboardToolbar.tintColor = [UIColor whiteColor];
        keyboardToolbar.barStyle = UIBarStyleBlackTranslucent;
        keyboardToolbar.items = @[extraSpace, accept];
        
        self.valueTextField.inputAccessoryView = keyboardToolbar;
    }
}

- (void) addCustomPicker {
    self.selectionStyle = UITableViewCellSelectionStyleDefault;
    
    _valueTextField.frame = CGRectMake(0, 0, 100, 30);
    _valueTextField.font = [UIFont systemFontOfSize:14];
    _valueTextField.textColor = [UIColor grayColor];
    _valueTextField.textAlignment = NSTextAlignmentCenter;
    _valueTextField.tintColor = [UIColor clearColor];
    
    self.accessoryView = self.valueTextField;
    
    [self setNeedsCustomPicker];
}

- (void) addTitleValue {
    self.selectionStyle = UITableViewCellSelectionStyleDefault;
    
    _valueTextField.frame = CGRectMake(0, 0, 100, 30);
    _valueTextField.font = [UIFont systemFontOfSize:14];
    _valueTextField.textColor = [UIColor grayColor];
    _valueTextField.textAlignment = NSTextAlignmentRight;
    _valueTextField.tintColor = [UIColor clearColor];
    
    self.valueTextField.inputAccessoryView = nil;
    
    self.accessoryView = self.valueTextField;
}

- (void) addSegmentControl {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.textLabel.font = [UIFont systemFontOfSize:12];
    
    if (!self.segmentControl) {
        self.segmentControl = [[UISegmentedControl alloc] init];
        self.segmentControl.frame = CGRectMake(15, 40, self.bounds.size.width - 30, 30);
        [self.segmentControl addTarget:self action:@selector(segmentIndexChanged) forControlEvents:UIControlEventValueChanged];
        [self addSubview:self.segmentControl];
    }
}

- (void) switchValueChanged {
    if ([self.delegate respondsToSelector:@selector(userInfoCellValueChanged:)]) {
        [self.delegate userInfoCellValueChanged:self];
    }
}

- (void) datePickerValueChanged {
    [_valueTextField resignFirstResponder];
    
    if ([self.delegate respondsToSelector:@selector(userInfoCellValueChanged:)]) {
        [self.delegate userInfoCellValueChanged:self];
    }
}

- (void) profileImageButtonClicked {
    if ([self.delegate respondsToSelector:@selector(userInfoCellDidSelectProfileImage:)]) {
        [self.delegate userInfoCellDidSelectProfileImage:self];
    }
}

- (void) customPickerValueChanged {
    [_valueTextField resignFirstResponder];
    
    if ([self.delegate respondsToSelector:@selector(userInfoCellValueChanged:)]) {
        [self.delegate userInfoCellValueChanged:self];
    }
}

- (void) segmentIndexChanged {
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
}

- (NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.customPickerValues[component][row];
}


#pragma mark - Pubic Methods

- (void) layoutSubviews {
    [super layoutSubviews];
    
    self.separatorLayer.frame = CGRectMake(15, self.bounds.size.height - 1, self.bounds.size.width - 15, 0.5);
    
    if (self.type == APCUserInfoCellTypeSingleInputText) {
        self.valueTextField.frame = CGRectMake(15, (self.bounds.size.height - 30) * 0.5, 300, 30);
    }
    else if (self.type == APCUserInfoCellTypeImageText) {
        CGFloat leftInset = 15 + 80 + 10;
        
        self.valueTextField.frame = CGRectMake(leftInset, ((self.bounds.size.height - 30) * 0.5) - 10, 300 - leftInset, 30);
        
        self.profileImageButton.frame = CGRectMake(15, (self.bounds.size.height - 70) * 0.5, 70, 70);
        
        self.separatorLayer.frame = CGRectMake(leftInset, CGRectGetMaxY(self.valueTextField.frame) + 3, self.bounds.size.width - leftInset, 1);
        
        self.profileImageCircleLayer.frame = self.profileImageButton.frame;
    }
    else if (self.type == APCUserInfoCellTypeSegment) {
        [self.textLabel sizeToFit];
        
        CGRect frame = self.textLabel.frame;
        frame.origin.y = 9;
        self.textLabel.frame = frame;
        
        frame = self.segmentControl.frame;
        frame.origin.y = CGRectGetMaxY(self.textLabel.frame) + 9;
        self.segmentControl.frame = frame;
    }
}

- (void) prepareForReuse {
    [super prepareForReuse];
    
    _valueTextField.frame = CGRectMake(15, 7, 140, 30);
    
    self.textLabel.text = nil;
    self.detailTextLabel.text = nil;
    
    [self.segmentControl removeAllSegments];
}

- (void) setNeedsHiddenField {
    _valueTextField.hidden = YES;
    [self addSubview:_valueTextField];
}

- (void) setNeedsCustomPicker {
    {
        if (!self.customPickerValues) {
            self.customPickerView = [[UIPickerView alloc] init];
            self.customPickerView.backgroundColor = [UIColor whiteColor];
            self.customPickerView.dataSource = self;
            self.customPickerView.delegate = self;
        }
        
        self.valueTextField.inputView = self.customPickerView;
    }
    
    {
        if (!self.valueTextField.inputAccessoryView) {
            UIBarButtonItem *extraSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
            UIBarButtonItem *accept = [[UIBarButtonItem alloc] initWithTitle:@"Select" style:UIBarButtonItemStyleDone target:self action:@selector(customPickerValueChanged)];
            
            UIToolbar *keyboardToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 44)];
            keyboardToolbar.tintColor = [UIColor whiteColor];
            keyboardToolbar.barStyle = UIBarStyleBlackTranslucent;
            keyboardToolbar.items = @[extraSpace, accept];
            
            self.valueTextField.inputAccessoryView = keyboardToolbar;
        }
    }
}

@end
