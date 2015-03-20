/*
 Copyright (c) 2015, Apple Inc. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 1.  Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 2.  Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation and/or
 other materials provided with the distribution.
 
 3.  Neither the name of the copyright holder(s) nor the names of any contributors
 may be used to endorse or promote products derived from this software without
 specific prior written permission. No license is granted to the trademarks of
 the copyright holders even if such marks are included in this software.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */



#import "ORKSurveyAnswerCellForNumber.h"
#import "ORKSkin.h"
#import "ORKAnswerFormat_Internal.h"
#import "ORKHelpers.h"
#import "ORKQuestionStep_Internal.h"
#import "ORKTextFieldView.h"


@interface ORKSurveyAnswerCellForNumber ()

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) ORKTextFieldView *textFieldView;

@end

@implementation ORKSurveyAnswerCellForNumber
{
    NSNumberFormatter *_numberFormatter;
}

- (ORKUnitTextField *)textField {
    return _textFieldView.textField;
}

- (void)_numberCell_initialize
{
    ORKQuestionType questionType = self.step.questionType;
    _numberFormatter = [(ORKNumericAnswerFormat *)[[self.step answerFormat] _impliedAnswerFormat] _makeNumberFormatter];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_localeDidChange:) name:NSCurrentLocaleDidChangeNotification object:nil];
    
    _textFieldView = [[ORKTextFieldView alloc] init];
    ORKUnitTextField *textField =  _textFieldView.textField;
    
    textField.delegate = self;
    textField.allowsSelection = YES;
    
    
    if (questionType == ORKQuestionTypeDecimal)
    {
        textField.keyboardType = UIKeyboardTypeDecimalPad;
    }
    else if (questionType == ORKQuestionTypeInteger)
    {
        textField.keyboardType = UIKeyboardTypeNumberPad;
    }
    
    [textField addTarget:self action:@selector(_valueFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    _containerView = [[UIView alloc] init];
    _containerView.backgroundColor = textField.backgroundColor;
    [_containerView addSubview: _textFieldView];

    [self addSubview:_containerView];
    
    ORKEnableAutoLayoutForViews(@[_containerView, _textFieldView]);
        
    [self setNeedsUpdateConstraints];
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)_localeDidChange:(NSNotification *)note {
    // On a locale change, re-format the value with the current locale
    _numberFormatter.locale = [NSLocale currentLocale];
    [self _answerDidChange];
}

- (void)setNeedsUpdateConstraints
{
    [NSLayoutConstraint deactivateConstraints:[self constraints]];
    [NSLayoutConstraint deactivateConstraints:[_containerView constraints]];
    [super setNeedsUpdateConstraints];
}


- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    self.layoutMargins = (UIEdgeInsets){.left=ORKStandardMarginForView(self),.right=ORKStandardMarginForView(self),.bottom=8,.top=8};
    [self setNeedsUpdateConstraints];
}

- (void)updateConstraints
{
    NSDictionary *views = NSDictionaryOfVariableBindings(_containerView, _textFieldView);
    self.layoutMargins = (UIEdgeInsets){.left=ORKStandardMarginForView(self),.right=ORKStandardMarginForView(self),.bottom=8,.top=8};
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_containerView]-|"
                                                                 options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_containerView(>=0)]-|"
                                                                 options:0 metrics:nil views:views]];
    
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_textFieldView]|" options:0 metrics:nil views:views]];
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_textFieldView]|" options:0 metrics:nil views:views]];

    
    [super updateConstraints];
    
}

- (BOOL)becomeFirstResponder {
    return [[self textField] becomeFirstResponder];
}

- (void)prepareView {
    
    if (self.textField == nil ) {
        [self _numberCell_initialize];
    }
    
    [self _answerDidChange];
    
    [super prepareView];
}

- (BOOL)_isAnswerValid {
    id answer = self.answer;
    
    if (answer == ORKNullAnswerValue()) {
        return YES;
    }
    
    ORKAnswerFormat *answerFormat = [self.step _impliedAnswerFormat];
    ORKNumericAnswerFormat *numericFormat = (ORKNumericAnswerFormat *)answerFormat;
    return [numericFormat _isAnswerValidWithString:self.textField.text];
}

- (BOOL)shouldContinue {
    BOOL isValid = [self _isAnswerValid];

    if (! isValid) {
        [self _showValidityAlertWithMessage:[[self.step _impliedAnswerFormat] _localizedInvalidValueStringWithAnswerString:self.textField.text]];
    }
    
    return isValid;
}


- (void)_answerDidChange
{
    id answer = self.answer;
    ORKAnswerFormat *answerFormat = [self.step _impliedAnswerFormat];
    ORKNumericAnswerFormat *numericFormat = (ORKNumericAnswerFormat *)answerFormat;
    NSString *displayValue = (answer && answer != ORKNullAnswerValue()) ? answer : nil;
    if ([answer isKindOfClass:[NSNumber class]])
    {
        displayValue = [_numberFormatter stringFromNumber:answer];
    }
   
    NSString *placeholder = self.step.placeholder? : ORKLocalizedString(@"PLACEHOLDER_TEXT_OR_NUMBER", nil);

    self.textField.manageUnitAndPlaceholder = YES;
    self.textField.unit = numericFormat.unit;
    self.textField.placeholder = placeholder;
    self.textField.text = displayValue;
}


#pragma mark - UITextFieldDelegate

- (void)_valueFieldDidChange:(UITextField *)textField {
    
    ORKNumericAnswerFormat *answerFormat = (ORKNumericAnswerFormat *)[self.step _impliedAnswerFormat];
    NSString *sanitizedText = [answerFormat _sanitizedTextFieldText:[textField text] decimalSeparator:[_numberFormatter decimalSeparator]];
    textField.text = sanitizedText;
    [self _setAnswerWithText:textField.text];
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    
    [self _setAnswer:ORKNullAnswerValue()];
    return YES;
}

- (void)_setAnswerWithText:(NSString *)text {
    BOOL updateInput = NO;
    id answer = ORKNullAnswerValue();
    if ([text length]) {
        answer = [[NSDecimalNumber alloc] initWithString:text locale:[NSLocale currentLocale]];
        if (! answer) {
            answer = ORKNullAnswerValue();
            updateInput = YES;
        }
    }
    
    [self _setAnswer:answer];
    if (updateInput) {
        [self _answerDidChange];
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    BOOL isValid = [self _isAnswerValid];
    if (! isValid) {
        [self _showValidityAlertWithMessage:[[self.step _impliedAnswerFormat] _localizedInvalidValueStringWithAnswerString:textField.text]];
    }
    
    return YES;
}


+ (BOOL)_shouldDisplayWithSeparators {
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    BOOL isValid = [self _isAnswerValid];
    
    if (! isValid)
    {
        [self _showValidityAlertWithMessage:[[self.step _impliedAnswerFormat] _localizedInvalidValueStringWithAnswerString:textField.text]];
        return NO;
    }
    
    [self.textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSString *text = self.textField.text;
    [self _setAnswerWithText:text];
}


@end
