//
//  APCCustomBackButton.h
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface APCCustomBackButton : UIButton

+ (APCCustomBackButton *)customBackButtonWithTarget:(id)aTarget action:(SEL)anAction tintColor:(UIColor *)aTintColor;
+ (UIBarButtonItem *)customBackBarButtonItemWithTarget:(id)aTarget action:(SEL)anAction tintColor:(UIColor *)aTintColor;

@end
