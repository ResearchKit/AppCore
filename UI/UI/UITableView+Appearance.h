//
//  UITableView+AppearanceCategory.h
//  UI
//
//  Created by Karthik Keyan on 9/5/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

@import UIKit;

@interface UITableView (Appearance)

+ (UIColor *) separatorColor;

// Footer
+ (UIFont *) footerFont;

+ (UIColor *) footerTextColor;


// Title
+ (UIFont *) textLabelFont;

+ (UIColor *) textLabelTextColor;


// Detail text
+ (UIFont *) detailLabelFont;

+ (UIColor *) detailLabelTextColor;


// Textfield inside cell
+ (UIFont *) textFieldFont;

+ (UIColor *) textFieldTextColor;


// Control Border Color
+ (CGFloat) controlsBorderWidth;

+ (UIColor *) controlsBorderColor;

@end
