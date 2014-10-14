//
//  APCPermissionsCell.m
//  APCAppleCore
//
//  Created by Ramsundar Shandilya on 9/19/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCPermissionsCell.h"
#import "UIColor+APCAppearance.h"

@interface APCPermissionsCell()

@property (unsafe_unretained, nonatomic) IBOutlet APCPermissionButton *permissionsButton;

@end

@implementation APCPermissionsCell

- (void)awakeFromNib
{
    self.backgroundColor = [UIColor colorWithWhite:248/255.f alpha:1.0];  
}

- (IBAction)permissionButtonTapped:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(permissionsCellTappedPermissionsButton:)]) {
        [self.delegate permissionsCellTappedPermissionsButton:self];
    }
}

- (void)setPermissionsGranted:(BOOL)granted
{
    [self.permissionsButton setSelected:granted];
}

@end

/* ---- */

#import "APCConfirmationView.h"

@interface APCPermissionButton ()

@property (nonatomic, strong) APCConfirmationView *confirmationView;

@end

static CGFloat kTitleLabelHeight      = 25.0f;
static CGFloat kConfirmationViewWidth = 22.0f;
static CGFloat kViewsPadding           = 10.f;

@implementation APCPermissionButton

@synthesize titleLabel = _titleLabel;

- (void)awakeFromNib
{
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:self.titleLabel];
    
    self.confirmationView = [[APCConfirmationView alloc] init];
    self.confirmationView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.confirmationView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    NSString *title = self.titleLabel.text;
    
    CGFloat textWidth = [title boundingRectWithSize:CGSizeMake(200, 0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.titleLabel.font} context:nil].size.width;
    CGFloat totalWidth = kConfirmationViewWidth + kViewsPadding + textWidth;
    
    self.confirmationView.frame = CGRectMake((CGRectGetWidth(self.frame) - totalWidth)/2, (CGRectGetHeight(self.frame) - kConfirmationViewWidth)/2, kConfirmationViewWidth, kConfirmationViewWidth);
    self.titleLabel.frame = CGRectMake(CGRectGetMaxX(self.confirmationView.frame) + kViewsPadding, (CGRectGetHeight(self.frame) - kTitleLabelHeight)/2, textWidth, kTitleLabelHeight);
}

- (void)setSelected:(BOOL)selected
{
    if (selected) {
        self.titleLabel.text = NSLocalizedString(@"Access Granted", nil);
        [self.titleLabel setTextColor:[UIColor appTertiaryColor1]];
        
        self.confirmationView.completed = YES;
        self.enabled = NO;
        
    } else {
        self.titleLabel.text = NSLocalizedString(@"Grant Access", nil);
        [self.titleLabel setTextColor:[UIColor grayColor]];
        
        self.confirmationView.completed = NO;
        self.enabled = YES;
    }
    
    [self layoutSubviews];
}

@end