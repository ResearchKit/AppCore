// 
//  Activity 
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
 
#import "APCTheme.h"

@implementation APCTheme

+ (UIColor *)colorForRightCellBorder
{
    return [UIColor colorWithRed:0.757 green:0.094 blue:0.129 alpha:1.000];
}

+ (CGFloat)widthForRightCellBorder
{
    return 4.0;
}

+ (UIColor *)colorForDividerLine
{
    return [UIColor colorWithWhite:0.836 alpha:1.000];
}

+ (CGFloat)widthForDividerLine
{
    return 0.5;
}

+ (UIColor *)colorForActivityOutline
{
    return [UIColor colorWithWhite:0.973 alpha:1.000];
}

+ (UIColor *)colorForActivitySleep
{
    return [UIColor colorWithRed:0.145 green:0.851 blue:0.443 alpha:1.000];
}

+ (UIColor *)colorForActivityInactive
{
    return [UIColor colorWithRed:0.176 green:0.706 blue:0.980 alpha:1.000];
}

+ (UIColor *)colorForActivitySedentary
{
    return [UIColor colorWithRed:0.608 green:0.196 blue:0.867 alpha:1.000];
}

+ (UIColor *)colorForActivityModerate
{
    return [UIColor colorWithRed:0.957 green:0.745 blue:0.290 alpha:1.000];
}

+ (UIColor *)colorForActivityVigorous
{
    return [UIColor colorWithRed:0.937 green:0.267 blue:0.380 alpha:1.000];
}

@end
