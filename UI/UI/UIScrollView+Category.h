//
//  UIScrollView+Category.h
//  UI
//
//  Created by Karthik Keyan on 9/5/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScrollView (Category)

- (void) reduceSizeForKeyboardShowNotification:(NSNotification *)notification;

- (void) resizeForKeyboardHideNotification:(NSNotification *)notification;

@end
