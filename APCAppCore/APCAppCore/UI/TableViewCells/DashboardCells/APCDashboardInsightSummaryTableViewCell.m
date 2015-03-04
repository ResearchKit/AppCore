//
//  APCDashboardInsightSummaryTableViewCell.m
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
//
#import "APCDashboardInsightSummaryTableViewCell.h"

@interface APCDashboardInsightSummaryTableViewCell()

@property (nonatomic, weak) IBOutlet UILabel *summaryLabel;

@end

@implementation APCDashboardInsightSummaryTableViewCell

- (void)sharedInit
{
    _showTopSeparator = NO;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
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

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self sharedInit];
    }
    
    return self;
}

- (void)setSummaryCaption:(NSString *)summaryCaption
{
    _summaryCaption = summaryCaption;
    
    _summaryLabel.text = summaryCaption;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat borderWidth = 1.0;
    CGFloat topSeparatorWidth = rect.size.width;
    CGFloat topSeparatorHeight = 4.0;
    
    UIColor *borderColor = [UIColor lightGrayColor]; //[UIColor colorWithWhite:0.973 alpha:1.000];
    
    if (self.showTopSeparator) {
        CGRect topSeparator = CGRectMake(0, 0, topSeparatorWidth, topSeparatorHeight);
        UIColor *separatorColor = [UIColor colorWithWhite:0.910 alpha:1.000];
        [separatorColor setFill];
        UIRectFill(topSeparator);
    } else {
        // Top border
        CGContextSaveGState(context);
        CGContextSetLineCap(context, kCGLineCapSquare);
        CGContextSetStrokeColorWithColor(context, borderColor.CGColor);
        CGContextSetLineWidth(context, borderWidth);
        CGContextMoveToPoint(context, 0, 0);
        CGContextAddLineToPoint(context, rect.size.width, 0);
        CGContextStrokePath(context);
        CGContextRestoreGState(context);
    }
    
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
    CGFloat sidbarHeight = rect.size.height;// - (topBorderWidth + bottomBorderWidth);
    CGRect sidebar;
    
    if (self.showTopSeparator) {
        sidebar = CGRectMake(0, topSeparatorHeight, sidebarWidth, sidbarHeight);
    } else {
        sidebar = CGRectMake(0, 0, sidebarWidth, sidbarHeight);
    }
    UIColor *sidebarColor = self.sidebarColor;
    [sidebarColor setFill];
    UIRectFill(sidebar);
}

@end
