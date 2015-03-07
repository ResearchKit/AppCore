//
//  APCActivitiesTintedTableViewCell.m
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCActivitiesTintedTableViewCell.h"
#import "UIColor+APCAppearance.h"
#import "UIFont+APCAppearance.h"

NSString * const kAPCActivitiesTintedTableViewCellIdentifier = @"APCActivitiesTintedTableViewCell";

static CGFloat const kTitleLabelCenterYConstant = 10.5f;

@implementation APCActivitiesTintedTableViewCell

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    [self setupAppearance];
    
    self.countLabel.text = @"";
    
    self.hidesSubTitle = NO;
}

- (void)setupAppearance
{
    self.titleLabel.textColor = [UIColor appSecondaryColor1];
    self.titleLabel.font = [UIFont appRegularFontWithSize:16.f];
    
    self.subTitleLabel.textColor = [UIColor appSecondaryColor3];
    self.subTitleLabel.font = [UIFont appRegularFontWithSize:14.f];
}

- (void)setHidesSubTitle:(BOOL)hidesSubTitle
{
    _hidesSubTitle = hidesSubTitle;
    
    self.subTitleLabel.hidden = hidesSubTitle;
    
    if (hidesSubTitle) {
        self.titleLabelCenterYConstraint.constant = 0;
    } else {
        self.titleLabelCenterYConstraint.constant = kTitleLabelCenterYConstant;
    }
    
    [self layoutIfNeeded];
}

- (void)setTintColor:(UIColor *)tintColor
{
    if (!tintColor) {
        // default to the lightgray system color.
        tintColor = [UIColor lightGrayColor];
    }
    
    _tintColor = tintColor;
    
    self.tintView.backgroundColor = tintColor;
}

- (void)setupIncompleteAppearance
{
    self.titleLabel.textColor = [UIColor appSecondaryColor3];
    
    self.subTitleLabel.textColor = [UIColor appSecondaryColor3];
    
    self.countLabel.hidden = YES;
    
    self.tintView.backgroundColor = [UIColor appTertiaryGrayColor];
    
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat borderWidth = 0.25;
    
    UIColor *borderColor = [UIColor appBorderLineColor];
    
    // Top border
    CGContextSaveGState(context);
    CGContextSetLineCap(context, kCGLineCapSquare);
    CGContextSetStrokeColorWithColor(context, borderColor.CGColor);
    CGContextSetLineWidth(context, borderWidth);
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, rect.size.width, 0);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
    
    // Bottom border
    CGContextSaveGState(context);
    CGContextSetLineCap(context, kCGLineCapSquare);
    CGContextSetStrokeColorWithColor(context, borderColor.CGColor);
    CGContextSetLineWidth(context, borderWidth);
    CGContextMoveToPoint(context, 0, rect.size.height);
    CGContextAddLineToPoint(context, rect.size.width, rect.size.height);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
    
    // Sidebar
    CGFloat sidebarWidth = 4.0;
    CGFloat sidbarHeight = rect.size.height;
    CGRect sidebar = CGRectMake(0, 0, sidebarWidth, sidbarHeight);
    
    UIColor *sidebarColor = self.tintColor;
    [sidebarColor setFill];
    UIRectFill(sidebar);
}

@end
