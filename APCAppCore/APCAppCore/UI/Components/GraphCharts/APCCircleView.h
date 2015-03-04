// 
//  APCCircleView.h 
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//
 
#import <UIKit/UIKit.h>

@interface APCCircleView : UIView

@property (nonatomic, strong) UIColor *tintColor;

@property (nonatomic) CGFloat value;

- (CAShapeLayer *)shapeLayer;

@end
