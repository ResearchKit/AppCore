// 
//  APCCircularProgressView.h 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import <UIKit/UIKit.h>

@interface APCCircularProgressView : UIView

/*
 Range is 0 to 1.
 */
@property (nonatomic) IBInspectable CGFloat progress;

/*
 Color of the circular progress layer.
 */
@property (nonatomic, strong)IBInspectable UIColor *tintColor;

/*
 Color of the circular track layer.
 */
@property (nonatomic, strong) IBInspectable UIColor *trackColor;

/*
 Thickness of the progress arc. Defaults to 4.0.
 */
@property (nonatomic) IBInspectable CGFloat lineWidth;

/*
 Decides whether to hide the progress percentage Label. Defaults to NO.
 */
@property (nonatomic) IBInspectable BOOL hidesProgressValue;

/*
 Label which indicates the percentage of progress.
 */
@property (nonatomic, strong) UILabel *progressLabel;

/* 
 Duration of the animation. Defaults to 0.3
 */
@property (nonatomic) CFTimeInterval animationDuration;

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated;

@end
