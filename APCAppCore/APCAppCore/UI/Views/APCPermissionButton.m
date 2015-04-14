// 
//  APCPermissionButton.m 
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
 
#import "APCPermissionButton.h"
#import "APCConfirmationView.h"
#import "UIFont+APCAppearance.h"
#import "UIColor+APCAppearance.h"

@interface APCPermissionButton ()

@property (nonatomic, strong) APCConfirmationView *confirmationView;

@end

static CGFloat kTitleLabelHeight      = 25.0f;
static CGFloat kConfirmationViewWidth = 22.0f;
static CGFloat kViewsPadding          = 10.f;

@implementation APCPermissionButton

@synthesize titleLabel = _titleLabel;
@synthesize selected = _selected;

- (void)awakeFromNib
{
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.backgroundColor = [UIColor clearColor];
    [self.titleLabel setFont:[UIFont appRegularFontWithSize:16.0f]];
    [self addSubview:self.titleLabel];
    
    self.confirmationView = [[APCConfirmationView alloc] init];
    self.confirmationView.backgroundColor = [UIColor clearColor];
    self.confirmationView.userInteractionEnabled = NO;
    [self addSubview:self.confirmationView];
    
    self.imageView.hidden = YES;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    NSString *title = self.titleLabel.text;
     CGFloat textWidth = [title boundingRectWithSize:CGSizeMake(310, 0) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:self.titleLabel.font} context:nil].size.width;
    
    if (self.alignment == kAPCPermissionButtonAlignmentCenter) {
        
        CGFloat totalWidth = kConfirmationViewWidth + kViewsPadding + textWidth;
        
        self.confirmationView.frame = CGRectMake((CGRectGetWidth(self.frame) - totalWidth)/2, (CGRectGetHeight(self.frame) - kConfirmationViewWidth)/2, kConfirmationViewWidth, kConfirmationViewWidth);
        self.titleLabel.frame = CGRectMake(CGRectGetMaxX(self.confirmationView.frame) + kViewsPadding, (CGRectGetHeight(self.frame) - kTitleLabelHeight)/2, textWidth, kTitleLabelHeight);
    } else{
        self.confirmationView.frame = CGRectMake(10, (CGRectGetHeight(self.frame) - kConfirmationViewWidth)/2, kConfirmationViewWidth, kConfirmationViewWidth);
        self.titleLabel.frame = CGRectMake(CGRectGetMaxX(self.confirmationView.frame) + kViewsPadding, (CGRectGetHeight(self.frame) - kTitleLabelHeight)/2, CGRectGetWidth(self.frame) - CGRectGetMaxX(self.confirmationView.frame) - kViewsPadding, kTitleLabelHeight);
    }
    
}

- (BOOL)isSelected
{
    return _selected;
}

- (void)setSelected:(BOOL)selected
{
    _selected = selected;
    
    if (selected) {
        self.titleLabel.text = self.confirmedTitle;
        if (self.shouldHighlightText) {
            [self.titleLabel setTextColor:[UIColor appTertiaryColor1]];
        }
        
        self.confirmationView.completed = YES;
        self.enabled = NO;
        
    } else {
        self.titleLabel.text = self.unconfirmedTitle;
        [self.titleLabel setTextColor:[UIColor appSecondaryColor3]];
        
        self.confirmationView.completed = NO;
        self.enabled = YES;
    }
    
    [self setAttributed:_attributed];
    
    [self layoutSubviews];
}

#pragma mark - Setter methods

- (void)setConfirmedTitle:(NSString *)confirmedTitle
{
    _confirmedTitle = confirmedTitle;
    
    if (self.isSelected) {
        self.titleLabel.text = confirmedTitle;
    }
}

- (void)setUnconfirmedTitle:(NSString *)unconfirmedTitle
{
    _unconfirmedTitle = unconfirmedTitle;
    
    if (!self.isSelected) {
        self.titleLabel.text = unconfirmedTitle;
    }
}

- (void)setAttributed:(BOOL)attributed
{
    _attributed = attributed;
    
    if (attributed) {
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.unconfirmedTitle];
        
        [attributedString addAttribute:NSFontAttributeName value:[UIFont appRegularFontWithSize:15.0] range:NSMakeRange(0, 14)];
        [attributedString addAttribute:NSFontAttributeName value:[UIFont appMediumFontWithSize:15.0] range:NSMakeRange(15, 20)];
        
        [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor appSecondaryColor2] range:NSMakeRange(0, 14)];
        [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor appSecondaryColor1] range:NSMakeRange(15, 20)];
        
        
        self.titleLabel.attributedText = attributedString;
    }
}

@end
