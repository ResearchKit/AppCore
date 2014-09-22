//
//  APCParametersCellTableViewCell.m
//  ParametersDashboard
//
//  Created by Justin Warmkessel on 9/19/14.
//  Copyright (c) 2014 Justin Warmkessel. All rights reserved.
//

#import "APCParametersCell.h"

@interface APCParametersCell () 

@end

@implementation APCParametersCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier type:(InputCellType)type {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _txtTitle = [[UITextField alloc] initWithFrame:CGRectMake(10, 7, 140, 30)];
        _txtTitle.delegate = self;
        _txtTitle.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_txtTitle];
        
        [self setType:type];
    }
    
    return self;
}


#pragma mark - Custom Setter

- (void) setType:(InputCellType)type {
    if (_type != type) {
        _type = type;
        
        switch (self.type) {
            case InputCellTypeText:
                [self addText];
                break;
                
            case InputCellTypeSwitch:
                [self addSwitch];
                break;
                
            case InputCellTypeDatePicker:
                [self addPicker];
                break;
                
            case InputCellTypeEntity:
                self.selectionStyle = UITableViewCellSelectionStyleDefault;
                self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
                
            default:
                break;
        }
    }
}


#pragma mark - UITextFieldDelegate

- (void) textFieldDidEndEditing:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(inputCellValueChanged:)]) {
        [self.delegate inputCellValueChanged:self];
    }
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    return YES;
}


#pragma mark - Private Methods

- (void) addText {
    if (!self.txtValue) {
        self.txtValue = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 140, 30)];
        self.txtValue.delegate = self;
        self.txtValue.textAlignment = NSTextAlignmentRight;
    }
    
    self.txtValue.inputView = nil;
    self.txtValue.inputAccessoryView = nil;
    
    self.accessoryView = self.txtValue;
}

- (void) addSwitch {
    if (!self.switchView) {
        self.switchView = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 70, 30)];
        [self.switchView addTarget:self action:@selector(switchValueChanged) forControlEvents:UIControlEventValueChanged];
    }
    
    self.accessoryView = self.switchView;
}

- (void) addPicker {
    if (!self.txtValue) {
        self.txtValue = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 140, 30)];
        self.txtValue.delegate = self;
        self.txtValue.textAlignment = NSTextAlignmentRight;
    }
    
    self.accessoryView = self.txtValue;
    
    {
        self.datePicker = [[UIDatePicker alloc] init];
        self.datePicker.backgroundColor = [UIColor whiteColor];
        self.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
        
        self.txtValue.inputView = self.datePicker;
    }
    
    {
        UIBarButtonItem *extraSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *accept = [[UIBarButtonItem alloc] initWithTitle:@"Select" style:UIBarButtonItemStyleDone target:self action:@selector(datePickerValueChanged)];
        
        UIToolbar *keyboardToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 44)];
        keyboardToolbar.tintColor = [UIColor whiteColor];
        keyboardToolbar.barStyle = UIBarStyleBlackTranslucent;
        keyboardToolbar.items = @[extraSpace, accept];
        
        self.txtValue.inputAccessoryView = keyboardToolbar;
    }
}

- (void) switchValueChanged {
    if ([self.delegate respondsToSelector:@selector(inputCellValueChanged:)]) {
        [self.delegate inputCellValueChanged:self];
    }
}

- (void) datePickerValueChanged {
    [_txtValue resignFirstResponder];
    
    if ([self.delegate respondsToSelector:@selector(inputCellValueChanged:)]) {
        [self.delegate inputCellValueChanged:self];
    }
}


#pragma mark - Pubic Methods

- (void) prepareForReuse {
    [super prepareForReuse];
    
    self.textLabel.text = nil;
    self.detailTextLabel.text = nil;
}

- (id) value {
    id value;
    
    switch (self.type) {
        case InputCellTypeText:
            value = self.txtValue.text;
            break;
            
        case InputCellTypeSwitch:
            value = @(self.switchView.isOn);
            break;
            
        case InputCellTypeDatePicker:
            value = self.datePicker.date;
            break;
            
        default:
            break;
    }
    
    return value;
}

@end
