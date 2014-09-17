//
//  UIScrollView+Helper.h
//  AappleCore
//
//  Created by Karthik Keyan on 9/5/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

@import UIKit;

@interface UIScrollView (Helper)

- (void) reduceSizeForKeyboardShowNotification:(NSNotification *)notification;

- (void) resizeForKeyboardHideNotification:(NSNotification *)notification;

@end
