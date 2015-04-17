// 
//  APCActivitiesTintedTableViewCell.m 
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
    
    [self setNeedsDisplay];
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
