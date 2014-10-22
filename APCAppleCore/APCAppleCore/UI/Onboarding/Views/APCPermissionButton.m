//
//  APCPermissionButton.m
//  APCAppleCore
//
//  Created by Ramsundar Shandilya on 10/14/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
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
static CGFloat kViewsPadding           = 10.f;

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
    [self addSubview:self.confirmationView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    NSString *title = self.titleLabel.text;
    
    CGFloat textWidth = [title boundingRectWithSize:CGSizeMake(300, 0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.titleLabel.font} context:nil].size.width;
    CGFloat totalWidth = kConfirmationViewWidth + kViewsPadding + textWidth;
    
    self.confirmationView.frame = CGRectMake((CGRectGetWidth(self.frame) - totalWidth)/2, (CGRectGetHeight(self.frame) - kConfirmationViewWidth)/2, kConfirmationViewWidth, kConfirmationViewWidth);
    self.titleLabel.frame = CGRectMake(CGRectGetMaxX(self.confirmationView.frame) + kViewsPadding, (CGRectGetHeight(self.frame) - kTitleLabelHeight)/2, textWidth, kTitleLabelHeight);
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

@end
