//
//  APCFormTextField.m
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
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
