// 
//  UIScrollView+Helper.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "UIScrollView+Helper.h"

@implementation UIScrollView (Helper)

- (void) reduceSizeForKeyboardShowNotification:(NSNotification *)notification {
    CGFloat duration = 0.25;
    if ([[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey]) {
        duration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    }
    
    UIViewAnimationCurve animationCurve = UIViewAnimationCurveLinear;
    if ([[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey]) {
        animationCurve = [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    }
    
    CGRect keyBoardRect = CGRectZero;
    if ([[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey]) {
        [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyBoardRect];
    }
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationCurve:animationCurve];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    UIEdgeInsets inset = self.contentInset;
    inset.bottom = keyBoardRect.size.height;
    [self setContentInset:inset];
    
    inset = self.scrollIndicatorInsets;
    inset.bottom = keyBoardRect.size.height;
    [self setScrollIndicatorInsets:inset];
    
    [UIView commitAnimations];
}

- (void) resizeForKeyboardHideNotification:(NSNotification *)notification {
    CGFloat duration = 0.25;
    if ([[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey]) {
        duration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    }
    
    UIViewAnimationCurve animationCurve = UIViewAnimationCurveLinear;
    if ([[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey]) {
        animationCurve = [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    }
    
    CGRect keyBoardRect = CGRectZero;
    if ([[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey]) {
        [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyBoardRect];
    }
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationCurve:animationCurve];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    UIEdgeInsets inset = self.contentInset;
    inset.bottom -= keyBoardRect.size.height;
    inset.bottom = 0;
    
    [self setContentInset:inset];
    inset = self.scrollIndicatorInsets;
    inset.bottom = 0;
    [self setScrollIndicatorInsets:inset];
    
    [UIView commitAnimations];
}

@end
