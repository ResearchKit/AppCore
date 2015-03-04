// 
//  APCAxisView.h 
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//
 
#import <UIKit/UIKit.h>
#import "APCGraphConstants.h"

@interface APCAxisView : UIView

@property (nonatomic, getter=isLandscapeMode) BOOL landscapeMode;

@property (nonatomic, strong) UIColor *tintColor;

@property (nonatomic) CGFloat leftOffset;

- (void)setupLabels:(NSArray *)titles forAxisType:(APCGraphAxisType)type;

@end
