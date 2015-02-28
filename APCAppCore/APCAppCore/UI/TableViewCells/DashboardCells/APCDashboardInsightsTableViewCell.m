//
//  APCDashboardInsightTableViewCell.m
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCDashboardInsightsTableViewCell.h"
#import "UIColor+APCAppearance.h"

@interface APCDashboardInsightsTableViewCell()

@property (nonatomic, weak) IBOutlet UILabel *titleCaption;
@property (nonatomic, weak) IBOutlet UILabel *subtitleCaption;

@end

@implementation APCDashboardInsightsTableViewCell

- (void)awakeFromNib {
    
    [self.expandButton setImage:[[UIImage imageNamed:@"expand_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                       forState:UIControlStateNormal];
    
    [self.infoButton setImage:[[UIImage imageNamed:@"info_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                     forState:UIControlStateNormal];
    
    [self.infoButton setImage:[[UIImage imageNamed:@"info_icon_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                     forState:UIControlStateHighlighted];
    
    self.infoButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    self.showTopSeparator = NO;
}

- (IBAction) expandTapped: (UIButton *) __unused sender
{
    if([self.delegate respondsToSelector:@selector(dashboardInsightDidExpandForCell:)]){
        [self.delegate dashboardInsightDidExpandForCell:self];
    }
}

- (IBAction)infoTapped:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(dashboardInsightDidAskForMoreInfoForCell:)]) {
        [self.delegate dashboardInsightDidAskForMoreInfoForCell:self];
    }
}

- (void)setTintColor:(UIColor *)tintColor
{
    _tintColor = tintColor;
    [self.expandButton.imageView setTintColor:tintColor];
    [self.infoButton.imageView setTintColor:tintColor];
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
    
    //an NSDictionary of NSString => UIColor pairs
    NSDictionary * wordToColorMapping = @{@"good": [UIColor appTertiaryGreenColor], @"bad": [UIColor orangeColor]};
    
    NSMutableAttributedString * attributedString = [[NSMutableAttributedString alloc] initWithString:@""];
    
    NSArray *titleWords = [cellSubtitle componentsSeparatedByString:@" "];

    for (NSString *word in titleWords) {
        UIColor *wordColor = [wordToColorMapping valueForKey:word];
        
        if (wordColor) {
            NSDictionary *attributes = @{NSForegroundColorAttributeName: wordColor};
            NSAttributedString *coloredString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ ", word]
                                                                                attributes:attributes];
            [attributedString appendAttributedString:coloredString];
        } else {
            NSAttributedString *otherWord = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ ", word]];
            [attributedString appendAttributedString:otherWord];
        }
    }
    
    self.subtitleCaption.attributedText = attributedString;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat borderWidth = 1.0;
    CGFloat topSeparatorWidth = rect.size.width;
    CGFloat topSeparatorHeight = 7.0;
    CGFloat topBorderYValue = 0;
    
    UIColor *borderColor = [UIColor lightGrayColor];
    
    if (self.showTopSeparator) {
        CGRect topSeparator = CGRectMake(0, 0, topSeparatorWidth, topSeparatorHeight);
        UIColor *separatorColor = [UIColor colorWithWhite:0.973 alpha:1.000]; //[UIColor colorWithWhite:0.910 alpha:1.000];
        [separatorColor setFill];
        UIRectFill(topSeparator);
        
        topBorderYValue = topSeparatorHeight;
    }
    
    // Top border
    CGContextSaveGState(context);
    CGContextSetLineCap(context, kCGLineCapSquare);
    CGContextSetStrokeColorWithColor(context, borderColor.CGColor);
    CGContextSetLineWidth(context, borderWidth);
    CGContextMoveToPoint(context, 0, topBorderYValue);
    CGContextAddLineToPoint(context, rect.size.width, topBorderYValue);
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
    CGRect sidebar;
    
    if (self.showTopSeparator) {
        sidebar = CGRectMake(0, topSeparatorHeight, sidebarWidth, sidbarHeight);
    } else {
        sidebar = CGRectMake(0, 0, sidebarWidth, sidbarHeight);
    }
    
    UIColor *sidebarColor = self.tintColor;
    [sidebarColor setFill];
    UIRectFill(sidebar);
}

@end
