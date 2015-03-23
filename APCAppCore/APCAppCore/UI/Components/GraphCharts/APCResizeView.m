// 
//  APCResizeView.m 
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
 
#import "APCResizeView.h"

@implementation APCResizeView
@synthesize tintColor = _tintColor;

#pragma mark - Init

- (instancetype)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]) {
        // Initialization code
        [self setupView];
    }
    return self;
}

- (void)setupView
{
    self.backgroundColor = [UIColor clearColor];
    
    self.shapeLayer.frame = self.bounds;
    self.shapeLayer.path = [self layoutPath].CGPath;
    self.shapeLayer.fillColor = [UIColor clearColor].CGColor;
    self.shapeLayer.lineWidth = 1.0;
}

- (UIBezierPath *)layoutPath
{
    
    UIBezierPath *resizePath;
    
    if (self.type == kAPCResizeViewTypeExpand) {
        resizePath = [self zoomInPath];
    } else {
        resizePath = [self zoomOutPath];
    }
    
    return resizePath;
}

- (UIBezierPath *)zoomInPath
{
    UIBezierPath *zoomInPath = [UIBezierPath bezierPath];
    
    UIBezierPath *leftTopArrow = [self expandArrowPath];
    [zoomInPath appendPath:leftTopArrow];
    
    UIBezierPath *rightTopArrow = [self expandArrowPath];
    [rightTopArrow applyTransform:CGAffineTransformMakeRotation(M_PI_2)];
    [rightTopArrow applyTransform:CGAffineTransformMakeTranslation(CGRectGetWidth(self.frame), 0)];
    [zoomInPath appendPath:rightTopArrow];
    
    UIBezierPath *leftBottomArrow = [self expandArrowPath];
    [leftBottomArrow applyTransform:CGAffineTransformMakeRotation(-M_PI_2)];
    [leftBottomArrow applyTransform:CGAffineTransformMakeTranslation(0, CGRectGetHeight(self.frame))];
    [zoomInPath appendPath:leftBottomArrow];
    
    UIBezierPath *rightBottomArrow = [self expandArrowPath];
    [rightBottomArrow applyTransform:CGAffineTransformMakeRotation(M_PI)];
    [rightBottomArrow applyTransform:CGAffineTransformMakeTranslation(CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    [zoomInPath appendPath:rightBottomArrow];
    
    return zoomInPath;
}

- (UIBezierPath *)zoomOutPath
{
    UIBezierPath *zoomOutPath = [UIBezierPath bezierPath];
    
    UIBezierPath *leftTopArrow = [self collapseArrowPath];
    [zoomOutPath appendPath:leftTopArrow];
    
    UIBezierPath *rightTopArrow = [self collapseArrowPath];
    [rightTopArrow applyTransform:CGAffineTransformMakeRotation(M_PI_2)];
    [rightTopArrow applyTransform:CGAffineTransformMakeTranslation(CGRectGetWidth(self.frame), 0)];
    [zoomOutPath appendPath:rightTopArrow];
    
    UIBezierPath *leftBottomArrow = [self collapseArrowPath];
    [leftBottomArrow applyTransform:CGAffineTransformMakeRotation(-M_PI_2)];
    [leftBottomArrow applyTransform:CGAffineTransformMakeTranslation(0, CGRectGetHeight(self.frame))];
    [zoomOutPath appendPath:leftBottomArrow];
    
    UIBezierPath *rightBottomArrow = [self collapseArrowPath];
    [rightBottomArrow applyTransform:CGAffineTransformMakeRotation(M_PI)];
    [rightBottomArrow applyTransform:CGAffineTransformMakeTranslation(CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    [zoomOutPath appendPath:rightBottomArrow];
    
    return zoomOutPath;
}

- (UIBezierPath *)expandArrowPath
{
    UIBezierPath *arrow = [UIBezierPath bezierPath];
    [arrow moveToPoint:CGPointZero];
    [arrow addLineToPoint:CGPointMake(CGRectGetWidth(self.frame)*0.4, CGRectGetHeight(self.frame)*0.4)];
    [arrow moveToPoint:CGPointZero];
    [arrow addLineToPoint:CGPointMake(CGRectGetWidth(self.frame)*0.35, 0)];
    [arrow moveToPoint:CGPointZero];
    [arrow addLineToPoint:CGPointMake(0, CGRectGetHeight(self.frame)*0.35)];
    
    return arrow;
}

- (UIBezierPath *)collapseArrowPath
{
    UIBezierPath *arrow = [UIBezierPath bezierPath];
    [arrow moveToPoint:CGPointZero];
    [arrow addLineToPoint:CGPointMake(CGRectGetWidth(self.frame)*0.4, CGRectGetHeight(self.frame)*0.4)];
    [arrow moveToPoint:CGPointMake(CGRectGetWidth(self.frame)*0.1, CGRectGetHeight(self.frame)*0.4)];
    [arrow addLineToPoint:CGPointMake(CGRectGetWidth(self.frame)*0.4, CGRectGetHeight(self.frame)*0.4)];
    [arrow moveToPoint:CGPointMake(CGRectGetWidth(self.frame)*0.4, CGRectGetHeight(self.frame)*0.1)];
    [arrow addLineToPoint:CGPointMake(CGRectGetWidth(self.frame)*0.4, CGRectGetHeight(self.frame)*0.4)];
    
    return arrow;
}

#pragma mark - Custom Methods

+ (Class)layerClass {
    return CAShapeLayer.class;
}

- (CAShapeLayer *)shapeLayer {
    return (CAShapeLayer *)self.layer;
}

#pragma mark - View Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.shapeLayer.path = [self layoutPath].CGPath;
    self.shapeLayer.fillColor = [UIColor clearColor].CGColor;
}

#pragma mark - Setter methods

- (void)setTintColor:(UIColor *)tintColor
{
    _tintColor = tintColor;
    
    self.shapeLayer.strokeColor = _tintColor.CGColor;
}

- (void)setType:(APCResizeViewType)type
{
    _type = type;
    [self layoutSubviews];
}
@end
