// 
//  APCPasscodeViewController.h 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import <UIKit/UIKit.h>

@protocol APCPasscodeViewControllerDelegate;

@interface APCPasscodeViewController : UIViewController

@property (weak, nonatomic) id <APCPasscodeViewControllerDelegate> delegate;

@end

@protocol APCPasscodeViewControllerDelegate <NSObject>

- (void)passcodeViewControllerDidSucceed:(APCPasscodeViewController *)viewController;

@end
