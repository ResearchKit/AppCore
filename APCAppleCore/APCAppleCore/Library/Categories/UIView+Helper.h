//
//  UIView+Helper.h
//  APCAppleCore
//
//  Created by Karthik Keyan on 9/8/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
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

@end
