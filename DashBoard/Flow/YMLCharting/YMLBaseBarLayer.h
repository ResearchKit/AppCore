//
//  YMLBaseBarLayer.h
//  Avero
//
//  Created by Mark Pospesel on 1/24/13.
//  Copyright (c) 2013 ymedialabs.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "YMLChartEnumerations.h"

@interface YMLBaseBarLayer : CALayer

@property (nonatomic, assign) CGSize cornerRadii;
@property (nonatomic, assign) YMLChartOrientation orientation;

@end
