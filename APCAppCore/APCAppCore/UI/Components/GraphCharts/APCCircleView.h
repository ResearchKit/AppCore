// 
//  APCCircleView.h 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import <UIKit/UIKit.h>

@interface APCCircleView : UIView

@property (nonatomic, strong) UIColor *tintColor;

@property (nonatomic) CGFloat value;

- (CAShapeLayer *)shapeLayer;

@end
