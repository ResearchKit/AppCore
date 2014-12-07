// 
//  APCPermissionButton.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
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
