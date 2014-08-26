//
//  PieSliceLayer.h
//  PieChart
//
//  Created by Pavan Podila on 2/20/12.
//  Copyright (c) 2012 Pixel-in-Gene. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreFoundation/CoreFoundation.h>

@interface PieSliceLayer : CALayer


@property (nonatomic) CGFloat startAngle;
@property (nonatomic) CGFloat endAngle;
@property (nonatomic) CGFloat radius;
@property (nonatomic, strong) UIColor *fillColor;
@property (nonatomic, strong) UIColor *fillColor2;
@property (nonatomic) CGFloat strokeWidth;
@property (nonatomic, strong) UIColor *strokeColor;

@property (nonatomic, assign) CGFloat sliceShadowOpacity;

@property (nonatomic, strong, readonly) UIBezierPath *path;
@property (nonatomic, assign) CGGradientRef gradient;

@end
