// 
//  UIScrollView+Helper.h 
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
//
 
@import UIKit;

@interface UIScrollView (Helper)

- (void) reduceSizeForKeyboardShowNotification:(NSNotification *)notification;

- (void) resizeForKeyboardHideNotification:(NSNotification *)notification;

@end
