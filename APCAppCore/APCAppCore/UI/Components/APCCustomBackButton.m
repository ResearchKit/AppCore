// 
//  APCCustomBackButton.m 
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
 
#import "APCCustomBackButton.h"

static  const  CGFloat  kButtonWidth     = 30.0;
static  const  CGFloat  kButtonHeight    = 44.0;
static  const  CGFloat  kLayerWidth      = 30.0;
static  const  CGFloat  kLayerHeight     = 44.0;

static  const  CGFloat  kArrowLineWeight =  2.0;

@implementation APCCustomBackButton

+ (APCCustomBackButton *)customBackButtonWithTarget:(id)aTarget action:(SEL)anAction tintColor:(UIColor *)aTintColor
{
    APCCustomBackButton  *button = [APCCustomBackButton buttonWithType:UIButtonTypeCustom];
    CGRect  frame = CGRectMake(0.0, 0.0, kButtonWidth, kButtonHeight);
    button.frame = frame;
    [button addTarget:aTarget action:anAction forControlEvents:UIControlEventTouchUpInside];
    
    CGMutablePathRef  path = CGPathCreateMutable();
    
    CGPoint  p0 = CGPointMake(13.0, 12.0);
    CGPathMoveToPoint(path, NULL, p0.x, p0.y);
    
    CGPoint  p1 = CGPointMake(2.0, 22.0);
    CGPathAddLineToPoint(path, NULL, p1.x, p1.y);
    
    CGPoint  p2 = CGPointMake(13.0, 32.0);
    CGPathAddLineToPoint(path, NULL, p2.x, p2.y);
    
    CALayer  *layer = button.layer;
    CAShapeLayer  *shaper = [[CAShapeLayer alloc] init];
    shaper.frame = CGRectMake(0.0, 0.0, kLayerWidth, kLayerHeight);
    shaper.bounds = CGRectMake(0.0, 0.0, kLayerWidth, kLayerHeight);
    shaper.path = path;
    shaper.lineWidth = kArrowLineWeight;
    shaper.fillColor = [[UIColor clearColor] CGColor];
    shaper.contentsScale = [[UIScreen mainScreen] scale];
    shaper.strokeColor = aTintColor.CGColor;
    [layer addSublayer:shaper];
    
    CGPathRelease(path);
    
    return  button;
}

+ (UIBarButtonItem *)customBackBarButtonItemWithTarget:(id)aTarget action:(SEL)anAction tintColor:(UIColor *)aTintColor
{
    APCCustomBackButton  *button = [self customBackButtonWithTarget:aTarget action:anAction tintColor:aTintColor];
    UIBarButtonItem  *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    return  barButton;
}

@end
