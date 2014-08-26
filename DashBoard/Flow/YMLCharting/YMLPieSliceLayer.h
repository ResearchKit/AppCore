//
//  YMLPieSliceLayer.h
//  Avero
//
//  Created by Mark Pospesel on 12/18/12.
//  Copyright (c) 2012 ymedialabs.com. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

@interface YMLPieSliceLayer : CALayer

@property (nonatomic, strong, readonly) CAShapeLayer *strokeLayer;
@property (nonatomic, strong, readonly) CAGradientLayer *gradientLayer;
@property (nonatomic, readonly) CGFloat midAngle;
@property (nonatomic, readonly) CGPathRef path;

- (id)initWithStartAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle;

- (NSArray *)colors;
- (void)setColors:(NSArray *)colors;
- (void)setStartAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle radius:(CGFloat)radiusPercent animated:(BOOL)animated;
- (void)removeFromSuperlayerAnimated:(BOOL)animated;

+ (UIBezierPath *)slicePathWithStartAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle centerPoint:(CGPoint)centerPoint radius:(CGFloat)radius;
+ (NSArray *)keyframePathsWithDuration:(CGFloat) duration sourceStartAngle:(CGFloat)sourceStartAngle sourceEndAngle:(CGFloat)sourceEndAngle destinationStartAngle:(CGFloat)destinationStartAngle destinationEndAngle:(CGFloat)destinationEndAngle centerPoint:(CGPoint)centerPoint size:(CGSize)size sourceRadiusPercent:(CGFloat)sourceRadiusPercent destinationRadiusPercent:(CGFloat)destinationRadiusPercent;

@end
