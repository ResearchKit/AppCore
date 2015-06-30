// 
//  APCBaseGraphView.m 
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
 
#import "APCBaseGraphView.h"
#import "UIColor+APCAppearance.h"

static NSString * const kFadeAnimationKey = @"LayerFadeAnimation";
static NSString * const kGrowAnimationKey = @"LayerGrowAnimation";

CGFloat const kAPCFadeAnimationDuration = 0.2;
CGFloat const kAPCGrowAnimationDuration = 0.1;
CGFloat const kAPCPopAnimationDuration  = 0.3;

@implementation APCBaseGraphView

#pragma mark - Init

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self sharedInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self sharedInit];
    }
    return self;
}

- (void)sharedInit
{
    _axisColor = [UIColor colorWithRed:217/255.f green:217/255.f blue:217/255.f alpha:1.f];
    _axisTitleColor = [UIColor colorWithRed:142/255.f green:142/255.f blue:147/255.f alpha:1.f];
    _axisTitleFont = [UIFont fontWithName:@"HelveticaNeue" size:11.0f];
    
    _referenceLineColor = [UIColor colorWithRed:225/255.f green:225/255.f blue:225/255.f alpha:1.f];
    _secondaryTintColor = [UIColor appTertiaryBlueColor];
    
    _scrubberLineColor = [UIColor grayColor];
    _scrubberThumbColor = [UIColor colorWithWhite:1 alpha:1.0];
    
    _showsVerticalReferenceLines = NO;
    _showsHorizontalReferenceLines = YES;
    
    _hidesDataPoints = NO;
    _disableScrubbing = NO;
    _hidesYAxis = NO;
    _shouldHighlightXaxisLastTitle = YES;
    
    _emptyText = NSLocalizedString(@"No Data", @"No Data");
    
}

- (void)throwOverrideException
{
    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"%s must be overridden in a subclass/category", __PRETTY_FUNCTION__] userInfo:nil];
}

- (NSInteger)numberOfPlots
{
    [self throwOverrideException];
    
    return 0;
}

- (NSInteger)numberOfPointsInPlot:(NSInteger) __unused plotIndex
{
    [self throwOverrideException];
    
    return 0;
}

- (void)scrubReferenceLineForXPosition:(CGFloat) __unused xPosition
{
    [self throwOverrideException];
}

- (void)setScrubberViewsHidden:(BOOL) __unused hidden animated:(BOOL) __unused animated
{
    [self throwOverrideException];
}

- (void)refreshGraph
{
    [self throwOverrideException];
}

- (void)setDisableScrubbing:(BOOL)disableScrubbing
{
    _disableScrubbing = disableScrubbing;
    self.panGestureRecognizer.enabled = !disableScrubbing;
}

#pragma mark - Animations

- (void)animateLayer:(CAShapeLayer *)shapeLayer withAnimationType:(APCGraphAnimationType)animationType
{
    [self animateLayer:shapeLayer withAnimationType:animationType toValue:1.0];
}

- (void)animateLayer:(CAShapeLayer *)shapeLayer withAnimationType:(APCGraphAnimationType)animationType toValue:(CGFloat)toValue
{
    [self animateLayer:shapeLayer withAnimationType:animationType toValue:toValue startDelay:0.0];
}

- (void)animateLayer:(CAShapeLayer *)shapeLayer withAnimationType:(APCGraphAnimationType)animationType startDelay:(CGFloat)delay
{
    [self animateLayer:shapeLayer withAnimationType:animationType toValue:1.0 startDelay:delay];
}

- (void)animateLayer:(CAShapeLayer *)shapeLayer withAnimationType:(APCGraphAnimationType)animationType toValue:(CGFloat)toValue startDelay:(CGFloat)delay
{
    if (animationType == kAPCGraphAnimationTypeFade) {
        
        CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        fadeAnimation.beginTime = CACurrentMediaTime() + delay;
        fadeAnimation.fromValue = @0;
        fadeAnimation.toValue = @(toValue);
        fadeAnimation.duration = kAPCFadeAnimationDuration;
        fadeAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        fadeAnimation.fillMode = kCAFillModeForwards;
        fadeAnimation.removedOnCompletion = NO;
        [shapeLayer addAnimation:fadeAnimation forKey:kFadeAnimationKey];
        
    } else if (animationType == kAPCGraphAnimationTypeGrow) {
        
        CABasicAnimation *growAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        growAnimation.beginTime = CACurrentMediaTime() + delay;
        growAnimation.fromValue = @0;
        growAnimation.toValue = @(toValue);
        growAnimation.duration = kAPCGrowAnimationDuration;
        growAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        growAnimation.fillMode = kCAFillModeForwards;
        growAnimation.removedOnCompletion = NO;
        [shapeLayer addAnimation:growAnimation forKey:kGrowAnimationKey];
        
    } else if (animationType == kAPCGraphAnimationTypePop) {
        
        CABasicAnimation *popAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        popAnimation.beginTime = CACurrentMediaTime() + delay;
        popAnimation.fromValue = @0;
        popAnimation.toValue = @(toValue);
        popAnimation.duration = kAPCPopAnimationDuration;
        popAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        popAnimation.fillMode = kCAFillModeForwards;
        popAnimation.removedOnCompletion = NO;
        [shapeLayer addAnimation:popAnimation forKey:kGrowAnimationKey];
        
    }
}

@end
