//
//  APCBadgeLabel.m
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCBadgeLabel.h"
#import "UIColor+APCAppearance.h"

@implementation APCBadgeLabel

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self sharedInit];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self sharedInit];
    }
    
    return self;
}

- (void)sharedInit
{
    _tintColor = [UIColor appPrimaryColor];
    
    _lineWidth = 1.0f;
    
    self.layer.cornerRadius = CGRectGetHeight(self.bounds)/2;
    self.layer.masksToBounds = NO;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.layer.cornerRadius = CGRectGetHeight(self.bounds)/2;
    self.layer.borderColor  = self.tintColor.CGColor;
    self.layer.borderWidth  = 1.0;
}

- (void)setText:(NSString *)text
{
    [super setText:text];
    
    if (text == nil || [text isEqualToString:@""]) {
        self.layer.borderWidth = 0;
    } else {
        self.layer.borderWidth = 1.0;
    }
    
    [self setNeedsDisplay];
}

@end
