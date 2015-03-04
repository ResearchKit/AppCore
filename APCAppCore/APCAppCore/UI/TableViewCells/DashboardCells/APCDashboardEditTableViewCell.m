// 
//  APCDashboardEditTableViewCell.m 
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
//
 
#import "APCDashboardEditTableViewCell.h"
#import "UIFont+APCAppearance.h"
#import "UIColor+APCAppearance.h"

NSString *const kAPCDashboardEditTableViewCellIdentifier = @"APCDashboardEditTableViewCell";

@implementation APCDashboardEditTableViewCell

@synthesize tintColor = _tintColor;
@synthesize textLabel = _textLabel;

- (void)awakeFromNib {
    // Initialization code
    
    [self setupAppearance];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setupAppearance
{
    [self.textLabel setFont:[UIFont appRegularFontWithSize:19.0f]];
}

- (void)setTintColor:(UIColor *)tintColor
{
    _tintColor = tintColor;
    
    self.tintView.backgroundColor = tintColor;
    self.textLabel.textColor = tintColor;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat borderWidth = 1.0;
    CGFloat bottomBorderWidth = 0.0;

    // Bottom Border
    CGContextSaveGState(context);
    CGContextSetLineCap(context, kCGLineCapSquare);
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:0.85 alpha:1.0].CGColor);
    CGContextSetLineWidth(context, borderWidth);
    CGContextMoveToPoint(context, 0, rect.size.height - bottomBorderWidth);
    CGContextAddLineToPoint(context, rect.size.width, rect.size.height - bottomBorderWidth);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
    
    // Sidebar
    CGFloat sidebarWidth = 4.0;
    CGFloat sidbarHeight = rect.size.height - bottomBorderWidth;// - (topBorderWidth + bottomBorderWidth);
    CGRect sidebar = CGRectMake(0, 0, sidebarWidth, sidbarHeight);
    UIColor *sidebarColor = self.tintColor;
    [sidebarColor setFill];
    UIRectFill(sidebar);
}

@end
