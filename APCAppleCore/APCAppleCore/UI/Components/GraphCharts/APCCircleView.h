//
//  APCCircleView.h
//  YMLCharts
//
//  Created by Ramsundar Shandilya on 10/2/14.
//  Copyright (c) 2014 Ramsundar Shandilya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface APCCircleView : UIView

@property (nonatomic, strong) UIColor *tintColor;

@property (nonatomic) CGFloat value;

- (CAShapeLayer *)shapeLayer;

@end
