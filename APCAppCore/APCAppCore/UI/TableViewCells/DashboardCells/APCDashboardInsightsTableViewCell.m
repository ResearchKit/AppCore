// 
//  APCDashboardInsightsTableViewCell.m 
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

- (IBAction)infoTapped:(UIButton *) __unused sender
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
