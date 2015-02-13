//
//  APCInsightBarView.m
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCInsightBarView.h"
#import "UIColor+APCAppearance.h"

@implementation APCInsightBarView

- (void)drawRect:(CGRect)rect
{
    UIColor *goodBarColor = [UIColor appTertiaryGreenColor];
    UIColor *badBarColor = [UIColor lightGrayColor];
    CGFloat barHeight = 4.0;
    
    CGFloat goodWidth = 0;
    CGFloat badWidth  = 0;
    
    if (([self.goodDayValue doubleValue] != 0) || ([self.badDayValue doubleValue] != 0)) {
        if ([self.goodDayValue doubleValue] > [self.badDayValue doubleValue]) {
            goodWidth = rect.size.width;
            badWidth = rect.size.width * ([self.badDayValue doubleValue] / [self.goodDayValue doubleValue]);
        } else {
            goodWidth = rect.size.width * ([self.goodDayValue doubleValue] / [self.badDayValue doubleValue]);
            badWidth = rect.size.width;
        }
        
        // Good Bar
        CGRect barGood = CGRectMake(0, 0, goodWidth, barHeight);
        [goodBarColor setFill];
        UIRectFill(barGood);
        
        // Bad Bar
        CGRect barBad = CGRectMake(0, rect.size.height - barHeight, badWidth, barHeight);
        [badBarColor setFill];
        UIRectFill(barBad);
    }
}

- (void)setGoodDayValue:(NSNumber *)goodDayValue
{
    _goodDayValue = goodDayValue;
    
    [self setNeedsDisplay];
}

- (void)setBadDayValue:(NSNumber *)badDayValue
{
    _badDayValue = badDayValue;
    
    [self setNeedsDisplay];
}

@end
