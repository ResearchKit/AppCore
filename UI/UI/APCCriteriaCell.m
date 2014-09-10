//
//  APCCriteriaCell.m
//  UI
//
//  Created by Karthik Keyan on 9/3/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCCriteriaCell.h"
#import "UITableView+AppearanceCategory.h"

@interface APCCriteriaCell () <UITextFieldDelegate>

@end


@implementation APCCriteriaCell

- (void) awakeFromNib {
    [super awakeFromNib];
    
    self.textLabel.backgroundColor = [UIColor clearColor];
    
    UIColor *color = [UITableView controlsBorderColor];
    
    CGFloat borderWidth = [UITableView controlsBorderWidth];
    
    self.containerView.layer.borderWidth = borderWidth;
    self.containerView.layer.borderColor = color.CGColor;
    
    self.questionLabel.layer.borderWidth = borderWidth;
    self.questionLabel.layer.borderColor = color.CGColor;
    
    self.choice1.layer.borderWidth = borderWidth;
    self.choice1.layer.borderColor = color.CGColor;
    
    self.choice2.layer.borderWidth = borderWidth;
    self.choice2.layer.borderColor = color.CGColor;
    
    self.choice3.layer.borderWidth = borderWidth;
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
#warning assert message require
            NSAssert(NO, NSLocalizedString(@"ASSERT_MESSAGE", @""));
            break;
    }
}

- (void) prepareForReuse {
    [super prepareForReuse];
    
    self.choice1.selected = NO;
    self.choice2.selected = NO;
    self.choice3.selected = NO;
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
#warning assert message require
                NSAssert(NO, NSLocalizedString(@"ASSERT_MESSAGE", @""));
                break;
        }
    }
}


- (void) setNeedsChoiceInputCell {
    self.choice3.hidden = NO;
    self.choice2.hidden = NO;
    self.choice1.hidden = NO;
    
    self.captionLabel.hidden = YES;
    self.answerTextField.hidden = YES;
    
    [self removeDatePicker];
}

- (void) setNeedsTextInputCell {
    self.choice3.hidden = YES;
    self.choice2.hidden = YES;
    self.choice1.hidden = YES;
    
    self.captionLabel.hidden = NO;
    self.answerTextField.hidden = NO;
    
    [self removeDatePicker];
}

- (void) setNeedsDateInputCell {
    self.choice3.hidden = YES;
    self.choice2.hidden = YES;
    self.choice1.hidden = YES;
    
    self.captionLabel.hidden = NO;
    self.answerTextField.hidden = NO;
    
    if (!self.datePicker) {
        self.datePicker = [[UIDatePicker alloc] init];
        self.datePicker.backgroundColor = [UIColor whiteColor];
        self.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
        [self.datePicker addTarget:self action:@selector(datePickerValueChanged) forControlEvents:UIControlEventValueChanged];
    }
    
    self.answerTextField.inputView = self.datePicker;
}

- (NSUInteger) selectedChoiceIndex {
    NSUInteger index;
    
    if (self.choice1.isSelected) {
        index = 0;
    }
    else if (self.choice2.isSelected) {
        index = 1;
    }
    else {
        index = 2;
    }
    
    return index;
}

- (void) setSelectedChoiceIndex:(NSUInteger)index {
    self.choice1.selected = NO;
    self.choice2.selected = NO;
    self.choice3.selected = NO;
    
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
#warning assert message require
            NSAssert(NO, NSLocalizedString(@"ASSERT_MESSAGE", @""));
            break;
    }
}


#pragma mark - IBActions

- (IBAction) choiceDidChoose:(id)sender {
    self.choice1.selected = NO;
    self.choice2.selected = NO;
    self.choice3.selected = NO;
    
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
