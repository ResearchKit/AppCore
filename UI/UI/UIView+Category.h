//
//  UIView+Category.h
//  UI
//
//  Created by Karthik Keyan on 9/8/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Category)

+ (void) frame:(CGRect *)frame animationDuration:(CGFloat *)duration animationCurve:(UIViewAnimationCurve *)animationCurve fromKeyboardNotification:(NSNotification *)notification;

@end
