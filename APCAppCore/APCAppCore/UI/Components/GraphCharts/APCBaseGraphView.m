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

static NSString * const kAPCFadeAnimationKey   = @"APCFadeAnimationKey";
static NSString * const kAPCStrokeAnimationKey = @"APCStrokeAnimationKey";
static NSString * const kAPCScaleAnimationKey  = @"APCScaleAnimationKey";
static NSString * const kAPCPathAnimationKey   = @"APCPathAnimationKey";

CGFloat const kAPCFadeAnimationDuration   = 0.2;
CGFloat const kAPCStrokeAnimationDuration = 0.1;
CGFloat const kAPCScaleAnimationDuration  = 0.3;
CGFloat const kAPCPathAnimationDuration   = 0.7;

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

- (void)animateLayer:(CAShapeLayer *)shapeLayer withAnimationType:(APCGraphAnimationType)animationType toValue:(id)toValue startDelay:(CGFloat)delay
{
    NSString *animationKeyPath;
    NSString *animationKeyName;
    CFTimeInterval animationDuration = 0;
    
    if (animationType == kAPCGraphAnimationTypeFade) {
        
        animationKeyPath = @"opacity";
        animationKeyName = kAPCFadeAnimationKey;
        animationDuration =  kAPCFadeAnimationDuration;
        
    } else if (animationType == kAPCGraphAnimationTypeStrokeStart) {
        
        animationKeyPath = @"strokeStart";
        animationKeyName = kAPCStrokeAnimationKey;
        animationDuration =  kAPCStrokeAnimationDuration;
        
    } else if (animationType == kAPCGraphAnimationTypeStrokeEnd) {
        
        animationKeyPath = @"strokeEnd";
        animationKeyName = kAPCStrokeAnimationKey;
        animationDuration =  kAPCStrokeAnimationDuration;
        
    }else if (animationType == kAPCGraphAnimationTypeScale) {
        
        animationKeyPath = @"transform.scale";
        animationKeyName = kAPCScaleAnimationKey;
        animationDuration =  kAPCScaleAnimationDuration;
        
    } else if (animationType == kAPCGraphAnimationTypePath){
        animationKeyPath = @"path";
        animationKeyName = kAPCPathAnimationKey;
        animationDuration =  kAPCPathAnimationDuration;
    }
    
    CABasicAnimation *growAnimation = [CABasicAnimation animationWithKeyPath:animationKeyPath];
    growAnimation.beginTime = CACurrentMediaTime() + delay;
    growAnimation.toValue = toValue;
    growAnimation.duration = animationDuration;
    growAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    growAnimation.fillMode = kCAFillModeForwards;
    growAnimation.removedOnCompletion = NO;
    [shapeLayer addAnimation:growAnimation forKey:animationKeyName];
}

@end
