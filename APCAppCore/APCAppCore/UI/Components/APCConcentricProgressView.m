// 
//  APCConcentricProgressView.m 
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
 
#import "APCConcentricProgressView.h"

static NSString * const kAPCAnimationKey = @"APCAnimationKey";

@interface APCConcentricProgressView()

@property (nonatomic, strong) NSMutableArray *progressLayers;

@end

@implementation APCConcentricProgressView

#pragma mark - Init methods

- (id)initWithFrame:(CGRect)frame
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

- (void)sharedInit
{
    _progressLayers = [NSMutableArray new];
    
    _lineWidth = 5.0f;
    _shouldAnimate = YES;
}

- (NSUInteger)numberOfComponents
{
    NSUInteger numberOfComponents = 0;
    if ([self.datasource respondsToSelector:@selector(numberOfComponentsInConcentricProgressView)]){
        numberOfComponents = [self.datasource numberOfComponentsInConcentricProgressView];
    }
    
    return numberOfComponents;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.progressLayers removeAllObjects];
    [self.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    
    NSUInteger numberOfComponents = [self numberOfComponents];
    
    for (NSUInteger i=0; i < numberOfComponents; i++) {
        
        CAShapeLayer *dashedTrackLayer = [CAShapeLayer layer];
        [dashedTrackLayer setFrame:self.bounds];
        [dashedTrackLayer setFillColor:[UIColor clearColor].CGColor];
        dashedTrackLayer.path = [self circularArcPathForComponentAtIndex:i].CGPath;
        dashedTrackLayer.lineDashPattern = @[@8, @8];
        dashedTrackLayer.opacity = 0.3;
        [self.layer addSublayer:dashedTrackLayer];
        
        CAShapeLayer *progressLayer = [CAShapeLayer layer];
        [progressLayer setFrame:self.bounds];
        [progressLayer setFillColor:[UIColor clearColor].CGColor];
        progressLayer.path = [self circularArcPathForComponentAtIndex:i].CGPath;
        progressLayer.lineWidth = self.lineWidth;
        [self.layer addSublayer:progressLayer];
        
        if ([self.datasource respondsToSelector:@selector(concentricProgressView:colorForComponentAtIndex:)]) {
            dashedTrackLayer.strokeColor = [self.datasource concentricProgressView:self colorForComponentAtIndex:i].CGColor;
            progressLayer.strokeColor = [self.datasource concentricProgressView:self colorForComponentAtIndex:i].CGColor;
        } else{
            dashedTrackLayer.strokeColor = [UIColor grayColor].CGColor;
            progressLayer.strokeColor = [UIColor grayColor].CGColor;
        }
        
        if ([self.datasource respondsToSelector:@selector(concentricProgressView:valueForComponentAtIndex:)] && self.shouldAnimate) {
            progressLayer.strokeEnd = 0;
        } else {
            progressLayer.strokeEnd = [self.datasource concentricProgressView:self valueForComponentAtIndex:i];
        }
        
        [self.progressLayers addObject:progressLayer];
    }
    
    if (self.shouldAnimate) {
        [self animatePaths];
    }
}

- (NSUInteger)maximumAllowedComponents
{
    CGFloat allowedWidth = CGRectGetWidth(self.bounds)/2 - 10;
    CGFloat spacingPerComponent = self.lineWidth * 2;
    
    return floor(allowedWidth/spacingPerComponent);
}

- (UIBezierPath *)circularArcPathForComponentAtIndex:(NSUInteger)index
{
    CGPoint center = CGPointMake(CGRectGetWidth(self.bounds)/2, CGRectGetHeight(self.bounds)/2);
    CGFloat radius = [self radiusForComponentAtIndex:index];
    
    CGFloat startAngle = -M_PI_2;
    CGFloat endAngle = 3*M_PI_2;
    
    UIBezierPath *circularArcBezierPath = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
    
    return circularArcBezierPath;
}

- (CGFloat)radiusForComponentAtIndex:(NSUInteger)index
{
    return (MIN(CGRectGetWidth(self.bounds)/2, CGRectGetHeight(self.bounds)/2) - self.lineWidth*index*2 - self.lineWidth/2);
}


- (void)animatePaths
{
    for (NSUInteger i=0; i < [self numberOfComponents]; i++) {
        
        CAShapeLayer *progressLayer = self.progressLayers[i];
        CGFloat value = [self.datasource concentricProgressView:self valueForComponentAtIndex:i];
        
        CABasicAnimation *progressAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        progressAnimation.duration = 0.8;
        progressAnimation.fromValue = @(0);
        progressAnimation.toValue = @(value);
        progressAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        progressAnimation.fillMode = kCAFillModeForwards;
        progressAnimation.removedOnCompletion = NO;
        [progressLayer addAnimation:progressAnimation forKey:kAPCAnimationKey];
    }
}


@end
