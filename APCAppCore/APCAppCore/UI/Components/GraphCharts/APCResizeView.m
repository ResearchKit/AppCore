// 
//  APCResizeView.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
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
