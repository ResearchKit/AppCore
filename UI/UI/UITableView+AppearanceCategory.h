//
//  UITableView+AppearanceCategory.h
//  UI
//
//  Created by Karthik Keyan on 9/5/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

@import UIKit;

@interface UITableView (AppearanceCategory)

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


// segment controller inside cell
+ (UIFont *) segmentControlFont;

+ (UIColor *) segmentControlTextColor;

+ (UIColor *) segmentControlSelectedTextColor;

@end
