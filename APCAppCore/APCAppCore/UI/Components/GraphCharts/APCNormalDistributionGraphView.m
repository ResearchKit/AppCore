//
//  APCNormalDistributionGraphView.m
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

#import "APCNormalDistributionGraphView.h"
#import "UIColor+APCAppearance.h"

@implementation APCNormalDistributionGraphView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
    }
    return self;
}

- (void)sharedInit
{
    [super sharedInit];
    
    self.smoothLines = YES;
    self.hidesDataPoints = YES;
    self.disableScrubbing = YES;
    self.showsVerticalReferenceLines = NO;
    self.showsHorizontalReferenceLines = NO;
    self.hidesYAxis = YES;
    self.shouldHighlightXaxisLastTitle = NO;
    self.showsFillPath = YES;
    
    _value = 0;
    
    _lineColor = [UIColor appTertiaryRedColor];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
}

- (void)refreshGraph
{
    [super refreshGraph];
    
    [self drawVerticalScore];
}

- (void)drawVerticalScore
{
    CGFloat xPosition = CGRectGetWidth(self.plotsView.bounds) * self.value;
    UIBezierPath *referenceLinePath = [UIBezierPath bezierPath];
    [referenceLinePath moveToPoint:CGPointMake(xPosition, 0)];
    [referenceLinePath addLineToPoint:CGPointMake(xPosition, CGRectGetHeight(self.plotsView.bounds))];
    
    CAShapeLayer *referenceLineLayer = [CAShapeLayer layer];
    referenceLineLayer.strokeColor = self.lineColor.CGColor;
    referenceLineLayer.path = referenceLinePath.CGPath;
    referenceLineLayer.lineWidth = self.isLandscapeMode ? 3 : 2;
    referenceLineLayer.opacity = 0;
    [self.plotsView.layer addSublayer:referenceLineLayer];
    
    [self animateLayer:referenceLineLayer withAnimationType:kAPCGraphAnimationTypeFade toValue:0.85 startDelay:1.0];
}

@end
