// 
//  UIView+Helper.h 
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//
 
@import UIKit;

@interface UIView (Helper)

- (CGFloat) top;

- (CGFloat) bottom;

- (CGFloat) left;

- (CGFloat) right;

- (CGFloat) width;

- (CGFloat) height;

- (CGFloat) innerWidth;

- (CGFloat) innerHeight;

- (CGFloat) horizontalCenter;

- (CGFloat) verticalCenter;

+ (void) frame:(CGRect *)frame animationDuration:(CGFloat *)duration animationCurve:(UIViewAnimationCurve *)animationCurve fromKeyboardNotification:(NSNotification *)notification;

- (UIImage *)blurredSnapshot;

- (UIImage *)blurredSnapshotDark;

@end
