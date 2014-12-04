// 
//  UIScrollView+Helper.h 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
@import UIKit;

@interface UIScrollView (Helper)

- (void) reduceSizeForKeyboardShowNotification:(NSNotification *)notification;

- (void) resizeForKeyboardHideNotification:(NSNotification *)notification;

@end
