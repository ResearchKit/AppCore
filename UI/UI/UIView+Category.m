//
//  UIView+Category.m
//  UI
//
//  Created by Karthik Keyan on 9/8/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "UIView+Category.h"

@implementation UIView (Category)

+ (void) frame:(CGRect *)frame animationDuration:(CGFloat *)duration animationCurve:(UIViewAnimationCurve *)animationCurve fromKeyboardNotification:(NSNotification *)notification {
    *duration = 0.25;
    
    if ([[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey]) {
        *duration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    }
    
    *animationCurve = UIViewAnimationCurveLinear;
    
    if ([[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey]) {
        *animationCurve = [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    }
    
    if ([[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey]) {
        [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:frame];
    }
}

@end
