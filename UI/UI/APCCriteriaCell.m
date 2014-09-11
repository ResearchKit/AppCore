//
//  APCCriteriaCell.m
//  UI
//
//  Created by Karthik Keyan on 9/3/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCCriteriaCell.h"
#import "UITableView+Appearance.h"

static CGFloat kAPCCriteriaCellContainerViewMargin  = 10;

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
    
    self.answerTextField.tintColor = [UIColor clearColor];
}

- (void) layoutSubviews {
    [super layoutSubviews];
    
    CGRect containerFrame = CGRectInset(self.bounds, kAPCCriteriaCellContainerViewMargin, kAPCCriteriaCellContainerViewMargin);
    containerFrame.size.height += kAPCCriteriaCellContainerViewMargin;
    
    self.containerView.frame = containerFrame;
    
    CGRect containerBounds = self.containerView.bounds;
    
    CGRect textLabelFrame;
    CGRect remainingFrame;
    
    CGRectDivide(containerBounds, &textLabelFrame, &remainingFrame, containerBounds.size.height/2, CGRectMinYEdge);
    self.questionLabel.frame = textLabelFrame;
    
    if (!self.segmentControl.isHidden) {
        [self.segmentControl setFrame:remainingFrame];
    }
    
    remainingFrame = CGRectInset(remainingFrame, kAPCCriteriaCellContainerViewMargin, 0);
    
    if (!self.captionLabel.isHidden) {
        CGRect captionFrame;
        CGRectDivide(remainingFrame, &captionFrame, &remainingFrame, remainingFrame.size.width/2, CGRectMinXEdge);
        self.captionLabel.frame = captionFrame;
    }
    
    if (!self.answerTextField.isHidden) {
        self.answerTextField.frame = remainingFrame;
    }
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
        
        [self.segmentControl removeAllSegments];
        
        for (int i = 0; i < self.choices.count; i++) {
            [self.segmentControl insertSegmentWithTitle:self.choices[i] atIndex:i animated:NO];
        }
    }
}


- (void) setNeedsChoiceInputCell {
    self.segmentControl.hidden = NO;
    
    self.captionLabel.hidden = YES;
    self.answerTextField.hidden = YES;
    
    [self removeDatePicker];
}

- (void) setNeedsTextInputCell {
    self.segmentControl.hidden = YES;
    
    self.captionLabel.hidden = NO;
    self.answerTextField.hidden = NO;
    
    [self removeDatePicker];
}

- (void) setNeedsDateInputCell {
    self.segmentControl.hidden = YES;
    
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
    return self.segmentControl.selectedSegmentIndex;
}

- (void) setSelectedChoiceIndex:(NSUInteger)index {
    [self.segmentControl setSelectedSegmentIndex:index];
}


#pragma mark - IBActions

- (IBAction) segmentValueChanged {
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
    if ([self.delegate respondsToSelector:@selector(criteriaCellValueChanged:)]) {
        [self.delegate criteriaCellValueChanged:self];
    }
}

@end
