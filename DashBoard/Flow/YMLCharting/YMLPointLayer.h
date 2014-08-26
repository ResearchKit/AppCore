//
//  YMLPointLayer.h
//  PieChartDemo
//
//  Created by Mark Pospesel on 10/22/12.
//  Copyright (c) 2012 Y Media Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "YMLChartEnumerations.h"

@interface YMLPointLayer : CALayer

@property (nonatomic, assign) CGSize size;
@property (nonatomic, strong) UIColor *fillColor;
@property (nonatomic, strong) UIColor *strokeColor;
@property (nonatomic, assign) CGFloat lineWidth;
@property (nonatomic, assign) YMLPointSymbol symbol;

@end
