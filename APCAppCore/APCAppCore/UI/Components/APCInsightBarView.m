// 
//  APCInsightBarView.m 
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
 
#import "APCInsightBarView.h"
#import "UIColor+APCAppearance.h"

@implementation APCInsightBarView

- (void)drawRect:(CGRect)rect
{
    UIColor *goodBarColor = [UIColor appTertiaryGreenColor];
    UIColor *badBarColor = [UIColor orangeColor];
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
