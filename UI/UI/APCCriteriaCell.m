//
//  APCCriteriaCell.m
//  UI
//
//  Created by Karthik Keyan on 9/3/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCCriteriaCell.h"

@interface APCCriteriaCell () <UITextFieldDelegate>

@end


@implementation APCCriteriaCell

- (void) awakeFromNib {
    [super awakeFromNib];
    
    self.textLabel.backgroundColor = [UIColor clearColor];
    
    UIColor *color = [UIColor colorWithWhite:0.8 alpha:0.5];
    
    self.containerView.layer.borderWidth = 1.0;
    self.containerView.layer.borderColor = color.CGColor;
    
    self.questionLabel.layer.borderWidth = 1.0;
    self.questionLabel.layer.borderColor = color.CGColor;
    
    self.choice1.layer.borderWidth = 1.0;
    self.choice1.layer.borderColor = color.CGColor;
    
    self.choice2.layer.borderWidth = 1.0;
    self.choice2.layer.borderColor = color.CGColor;
    
    self.choice3.layer.borderWidth = 1.0;
    self.choice3.layer.borderColor = color.CGColor;
}

- (void) layoutSubviews {
    [super layoutSubviews];
    
    self.choice1.frame = CGRectZero;
    self.choice2.frame = CGRectZero;
    self.choice3.frame = CGRectZero;
    
    CGRect bounds = self.containerView.bounds;
    
    CGFloat width = bounds.size.width;
    CGRect frame = CGRectMake(0, 0, width, bounds.size.height/2);
    self.textLabel.frame = frame;
    
    frame.origin.y = CGRectGetMaxY(frame);
    
    switch (self.choices.count) {
        case 1:
            self.choice1.frame = frame;
            break;
            
        case 2:
            width = bounds.size.width/2;
            
            frame.size.width = width;
            self.choice1.frame = frame;
            
            frame.origin.x = CGRectGetMaxX(frame) - 1;
            frame.size.width += 1;
            self.choice2.frame = frame;
            break;
            
        case 3:
            width = bounds.size.width/3;
            
            frame.size.width = width;
            self.choice1.frame = frame;
            
            frame.origin.x = CGRectGetMaxX(frame) - 1;
            frame.size.width += 1;
            self.choice2.frame = frame;
            
            frame.origin.x = CGRectGetMaxX(frame) - 1;
            self.choice3.frame = frame;
            break;
            
        default:
            break;
    }
}

- (void) prepareForReuse {
    [super prepareForReuse];
    
    self.choice1.selected = self.choice2.selected = self.choice3.selected = NO;
}


#pragma mark - UITextFieldDelegate


- (void) textFieldDidEndEditing:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(criteriaCellValueChanged:)]) {
        [self.delegate criteriaCellValueChanged:self];
    }
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    return YES;
}


#pragma mark - Public Methods

- (void) setChoices:(NSArray *)choices {
    if (_choices != choices) {
        _choices = choices;
        
        switch (self.choices.count) {
            case 1:
                [self.choice1 setTitle:self.choices[0] forState:UIControlStateNormal];
                break;
                
            case 2:
                [self.choice1 setTitle:self.choices[0] forState:UIControlStateNormal];
                [self.choice2 setTitle:self.choices[1] forState:UIControlStateNormal];
                break;
                
            case 3:
                [self.choice1 setTitle:self.choices[0] forState:UIControlStateNormal];
                [self.choice2 setTitle:self.choices[1] forState:UIControlStateNormal];
                [self.choice3 setTitle:self.choices[2] forState:UIControlStateNormal];
                break;
                
            default:
                break;
        }
    }
}


- (void) setNeedsChoiceInputCell {
    self.choice3.hidden = self.choice2.hidden = self.choice1.hidden = NO;
    self.captionLabel.hidden = self.answerTextField.hidden = YES;
    
    [self removeDatePicker];
}

- (void) setNeedsTextInputCell {
    self.choice3.hidden = self.choice2.hidden = self.choice1.hidden = YES;
    self.captionLabel.hidden = self.answerTextField.hidden = NO;
    
    [self removeDatePicker];
}

- (void) setNeedsDateInputCell {
    self.choice3.hidden = self.choice2.hidden = self.choice1.hidden = YES;
    self.captionLabel.hidden = self.answerTextField.hidden = NO;
    
    {
        if (!self.datePicker) {
            self.datePicker = [[UIDatePicker alloc] init];
            self.datePicker.backgroundColor = [UIColor whiteColor];
            self.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
        }
        
        self.answerTextField.inputView = self.datePicker;
    }
    
    {
        UIBarButtonItem *extraSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *accept = [[UIBarButtonItem alloc] initWithTitle:@"Select" style:UIBarButtonItemStyleDone target:self action:@selector(datePickerValueChanged)];
        
        UIToolbar *keyboardToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 44)];
        keyboardToolbar.tintColor = [UIColor whiteColor];
        keyboardToolbar.barStyle = UIBarStyleBlackTranslucent;
        keyboardToolbar.items = @[extraSpace, accept];
        
        self.answerTextField.inputAccessoryView = keyboardToolbar;
    }
}

- (NSUInteger) selectedChoiceIndex {
    return (self.choice1.isSelected)? 0 : ((self.choice2.isSelected) ? 1 : 2);
}

- (void) setSelectedChoiceIndex:(NSUInteger)index {
    self.choice1.selected = self.choice2.selected = self.choice3.selected = NO;
    
    switch (index) {
        case 0:
            self.choice1.selected = YES;
            break;
            
        case 1:
            self.choice2.selected = YES;
            break;
            
        case 2:
            self.choice3.selected = YES;
            break;
            
        default:
            break;
    }
}


#pragma mark - IBActions

- (IBAction) choiceDidChoose:(id)sender {
    self.choice1.selected = self.choice2.selected = self.choice3.selected = NO;
    
    [(UIButton *)sender setSelected:YES];
    
    if ([self.delegate respondsToSelector:@selector(criteriaCellValueChanged:)]) {
        [self.delegate criteriaCellValueChanged:self];
    }
}


#pragma mark - Private Methods

- (void) removeDatePicker {
    self.datePicker = nil;
    self.answerTextField.inputAccessoryView = nil;
    self.answerTextField.inputView = nil;
}

- (void) datePickerValueChanged {
    [self.answerTextField resignFirstResponder];
}

@end
