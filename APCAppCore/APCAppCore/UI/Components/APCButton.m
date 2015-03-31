// 
//  APCButton.m 
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
 
#import "APCButton.h"
#import "UIColor+APCAppearance.h"

@implementation APCButton

- (void)sharedInit
{
    self.layer.cornerRadius = 5.0;
    self.layer.borderColor = [[UIColor appPrimaryColor] CGColor];
    self.layer.borderWidth = 1.0;
    self.layer.masksToBounds = YES;
    
    // Appearance for normal state
    UIImage *normalBackground = [self imageWithColor:[UIColor whiteColor]];
    UIImage *selectedBackground = [self imageWithColor:[UIColor appPrimaryColor]];
    
    [self setTitleColor:[UIColor appPrimaryColor] forState:UIControlStateNormal];
    [self setBackgroundImage:normalBackground forState:UIControlStateNormal];
    
    // Highlight
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [self setBackgroundImage:selectedBackground forState:UIControlStateHighlighted];
    
    // Appearance for selected state
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self setBackgroundImage:selectedBackground forState:UIControlStateSelected];
    
    // Appearance for disabled state
    [self setTitleColor:[[UIColor blackColor] colorWithAlphaComponent:0.3f] forState:UIControlStateDisabled];
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

- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    self.layer.borderColor = enabled ? [[UIColor appPrimaryColor] CGColor] : [[[UIColor blackColor] colorWithAlphaComponent:0.3f] CGColor];
}

@end
