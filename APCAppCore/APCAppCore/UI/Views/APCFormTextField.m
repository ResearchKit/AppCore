// 
//  APCFormTextField.m 
//  APCAppCore 
// 
// Copyright (c) 2015, Apple Inc. All rights reserved. 
// 
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
// 
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
// 
// 2.  Redistributions in binary form must reproduce the above copyright notice, 
// this list of conditions and the following disclaimer in the documentation and/or 
// other materials provided with the distribution. 
// 
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors 
// may be used to endorse or promote products derived from this software without 
// specific prior written permission. No license is granted to the trademarks of 
// the copyright holders even if such marks are included in this software. 
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE 
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
// 
 
#import "APCFormTextField.h"

static CGFloat const kButtonWidth = 25.0f;

@implementation APCFormTextField

#pragma mark - Init

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self sharedInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self sharedInit];
    }
    return self;
}

- (void)sharedInit
{
    _validationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_validationButton addTarget:self action:@selector(validButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [_validationButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    _validationButton.transform = CGAffineTransformMakeScale(0, 0);
    [self addSubview:_validationButton];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.validationButton setFrame:CGRectMake(CGRectGetMaxX(self.bounds) - kButtonWidth, 0, kButtonWidth, CGRectGetHeight(self.bounds))];
}

#pragma mark -Overrider UITextField Methods

- (CGRect)textRectForBounds:(CGRect)bounds
{
    return UIEdgeInsetsInsetRect([super textRectForBounds:bounds], UIEdgeInsetsMake(0, 0, 0, 27));
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return [self textRectForBounds:bounds];
}

#pragma mark - Button Actions

- (void)validButtonTapped:(UIButton *) __unused sender
{
    if (!self.valid) {
        if ([self.validationDelegate respondsToSelector:@selector(formTextFieldDidTapValidButton:)]) {
            [self.validationDelegate formTextFieldDidTapValidButton:self];
        }
    }
}

#pragma mark - Public Methods

- (void)setValid:(BOOL)valid
{
    if (valid) {
        [self.validationButton setImage:[UIImage imageNamed:@"valid_icon"] forState:UIControlStateNormal];
    } else {
        [self.validationButton setImage:[UIImage imageNamed:@"invalid_icon"] forState:UIControlStateNormal];
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        self.validationButton.transform = CGAffineTransformMakeScale(1, 1);
    }];
    
    _valid = valid;
}

@end
