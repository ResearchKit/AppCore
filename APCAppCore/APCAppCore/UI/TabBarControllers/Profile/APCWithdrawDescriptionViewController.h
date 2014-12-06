//
//  APCWithdrawDescriptionViewController.h
//  AppCore
//
//  Copyright (c) 2014 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol APCWithdrawDescriptionViewControllerDelegate;

@interface APCWithdrawDescriptionViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextView *textView;

@property (weak, nonatomic) IBOutlet UIButton *doneButton;

@property (strong, nonatomic) NSString *descriptionText;

@property (weak , nonatomic) id <APCWithdrawDescriptionViewControllerDelegate> delegate;


@end

@protocol APCWithdrawDescriptionViewControllerDelegate <NSObject>

- (void)withdrawViewController:(APCWithdrawDescriptionViewController *)viewController didFinishWithDescription:(NSString *)text;

- (void)withdrawViewControllerDidCancel:(APCWithdrawDescriptionViewController *)viewController;

@end