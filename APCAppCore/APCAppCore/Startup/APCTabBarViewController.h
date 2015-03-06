//
//  APCTabBarViewController.h
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "APCPasscodeViewController.h"

@interface APCTabBarViewController : UITabBarController

@property (nonatomic) BOOL showPasscodeScreen;
@property (nonatomic, weak) id<APCPasscodeViewControllerDelegate> passcodeDelegate;

@end
