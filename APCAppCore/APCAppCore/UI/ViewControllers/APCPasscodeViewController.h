// 
//  APCPasscodeViewController.h 
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//
 
#import <UIKit/UIKit.h>

@protocol APCPasscodeViewControllerDelegate;

@interface APCPasscodeViewController : UIViewController

@property (weak, nonatomic) id <APCPasscodeViewControllerDelegate> delegate;

@end

@protocol APCPasscodeViewControllerDelegate <NSObject>

- (void)passcodeViewControllerDidSucceed:(APCPasscodeViewController *)viewController;

@end
