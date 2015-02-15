//
//  APCDashboardInsightTableViewCell.m
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCDashboardInsightsTableViewCell.h"

@interface APCDashboardInsightsTableViewCell()

@property (nonatomic, weak) IBOutlet UILabel *titleCaption;
@property (nonatomic, weak) IBOutlet UILabel *subtitleCaption;

@end

@implementation APCDashboardInsightsTableViewCell

- (void)awakeFromNib {
    
    [self.expandButton setImage:[[UIImage imageNamed:@"expand_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                       forState:UIControlStateNormal];
}

- (IBAction) expandTapped: (UIButton *) __unused sender
{
    if([self.delegate respondsToSelector:@selector(dashboardInsightDidExpandForCell:)]){
        [self.delegate dashboardInsightDidExpandForCell:self];
    }
}

- (void)setTintColor:(UIColor *)tintColor
{
    _tintColor = tintColor;
    [self.expandButton.imageView setTintColor:tintColor];
    self.titleCaption.textColor = self.tintColor;
}

- (void)setCellTitle:(NSString *)cellTitle
{
    _cellTitle = cellTitle;
    
    self.titleCaption.text = cellTitle;
}

- (void)setCellSubtitle:(NSString *)cellSubtitle
{
    _cellSubtitle = cellSubtitle;
    
    self.subtitleCaption.text = cellSubtitle;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat borderWidth = 1.0;
    
    UIColor *borderColor = [UIColor colorWithWhite:0.973 alpha:1.000];
    
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
