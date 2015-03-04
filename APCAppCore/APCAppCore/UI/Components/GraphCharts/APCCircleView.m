// 
//  APCCircleView.m 
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
//
 
#import "APCCircleView.h"

@implementation APCCircleView

@synthesize tintColor = _tintColor;

#pragma mark - Init

- (instancetype)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]) {
        // Initialization code
        [self setupCircle];
    }
    return self;
}

- (void)setupCircle
{
    self.backgroundColor = [UIColor clearColor];
    self.layer.borderWidth = 2.0f;
    
    self.shapeLayer.cornerRadius = self.frame.size.width / 2.0f;
    self.shapeLayer.path = [self layoutPath].CGPath;
}

- (UIBezierPath *)layoutPath
{
    return [UIBezierPath bezierPathWithOvalInRect:self.bounds];
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
    
    self.shapeLayer.cornerRadius = self.frame.size.width / 2.0f;
    self.shapeLayer.path = [self layoutPath].CGPath;
}

#pragma mark - Setter methods

- (void)setTintColor:(UIColor *)tintColor
{
    _tintColor = tintColor;
    
    self.shapeLayer.fillColor = [UIColor whiteColor].CGColor;
    self.shapeLayer.borderColor = _tintColor.CGColor;
}

@end
