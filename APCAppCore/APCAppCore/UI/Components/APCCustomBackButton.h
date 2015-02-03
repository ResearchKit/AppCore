//
//  APCCustomBackButton.h
//  AppCore
//
//  Copyright (c) 2014 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface APCCustomBackButton : UIButton

+ (APCCustomBackButton *)customBackButtonWithTarget:(id)aTarget action:(SEL)anAction tintColor:(UIColor *)aTintColor;
+ (UIBarButtonItem *)customBackBarButtonItemWithTarget:(id)aTarget action:(SEL)anAction tintColor:(UIColor *)aTintColor;

@end
