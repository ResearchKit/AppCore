//
//  ProfileCell.m
//  Configuration
//
//  Created by Karthik Keyan on 8/11/14.
//  Copyright (c) 2014 Karthik Keyan. All rights reserved.
//

#import "ProfileCell.h"
#import "NSString+Extension.h"

@interface ProfileCell () <UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, strong) CALayer *separatorLayer;
@property (nonatomic, strong) CALayer *profileImageCircleLayer;

@end

@implementation ProfileCell

- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier type:(ProfileCellType)type {
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

- (void) setType:(ProfileCellType)type {
    if (_type != type) {
        _type = type;
        
        switch (self.type) {
            case ProfileCellTypeImageText:
                [self addImageText];
                break;
                
            case ProfileCellTypeSingleInputText:
                [self addSingleInputText];
                break;
                
            case ProfileCellTypeSwitch:
                [self addSwitch];
                break;
                
            case ProfileCellTypeDatePicker:
                [self addDatePicker];
                break;
            
            case ProfileCellTypeCustomPicker:
                [self addCustomPicker];
                break;
                
            case ProfileCellTypeTitleValue:
                [self addTitleValue];
                break;
            
            default:
                break;
        }
    }
}


#pragma mark - UITextFieldDelegate

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    BOOL isValid = YES;
    
    if (self.valueTextRegularExpression) {
        isValid = [string isValidForRegex:self.valueTextRegularExpression];
    }
    
    return isValid;
}

- (void) textFieldDidEndEditing:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(profileCellValueChanged:)]) {
        [self.delegate profileCellValueChanged:self];
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
        self.datePicker = [[UIDatePicker alloc] init];
        self.datePicker.backgroundColor = [UIColor whiteColor];
        self.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
        
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

- (void) switchValueChanged {
    if ([self.delegate respondsToSelector:@selector(profileCellValueChanged:)]) {
        [self.delegate profileCellValueChanged:self];
    }
}

- (void) datePickerValueChanged {
    [_valueTextField resignFirstResponder];
    
    if ([self.delegate respondsToSelector:@selector(profileCellValueChanged:)]) {
        [self.delegate profileCellValueChanged:self];
    }
}

- (void) profileImageButtonClicked {
    if ([self.delegate respondsToSelector:@selector(profileCellDidSelectProfileImage:)]) {
        [self.delegate profileCellDidSelectProfileImage:self];
    }
}

- (void) customPickerValueChanged {
    [_valueTextField resignFirstResponder];
    
    if ([self.delegate respondsToSelector:@selector(profileCellValueChanged:)]) {
        [self.delegate profileCellValueChanged:self];
    }
}


#pragma mark - UIPickerViewDataSource

- (NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.customPickerValues.count;
}


#pragma mark - UIPickerViewDelegate

- (NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.customPickerValues[row];
}


#pragma mark - Pubic Methods

- (void) layoutSubviews {
    [super layoutSubviews];
    
    self.separatorLayer.frame = CGRectMake(15, self.bounds.size.height - 1, self.bounds.size.width - 15, 0.5);
    
    if (self.type == ProfileCellTypeSingleInputText) {
        self.valueTextField.frame = CGRectMake(15, (self.bounds.size.height - 30) * 0.5, 300, 30);
    }
    else if (self.type == ProfileCellTypeImageText) {
        CGFloat leftInset = 15 + 80 + 10;
        
        self.valueTextField.frame = CGRectMake(leftInset, ((self.bounds.size.height - 30) * 0.5) - 10, 300 - leftInset, 30);
        
        self.profileImageButton.frame = CGRectMake(15, (self.bounds.size.height - 70) * 0.5, 70, 70);
        
        self.separatorLayer.frame = CGRectMake(leftInset, CGRectGetMaxY(self.valueTextField.frame) + 3, self.bounds.size.width - leftInset, 1);
        
        self.profileImageCircleLayer.frame = self.profileImageButton.frame;
    }
}

- (void) prepareForReuse {
    [super prepareForReuse];
    
    _valueTextField.frame = CGRectMake(15, 7, 140, 30);
    
    self.textLabel.text = nil;
    self.detailTextLabel.text = nil;
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
