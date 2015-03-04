// 
//  APCTermsAndConditionsViewController.h 
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//
 
#import <UIKit/UIKit.h>

@protocol APCTermsAndConditionsViewControllerDelegate;

@interface APCTermsAndConditionsViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextView *textView;

@property (weak, nonatomic) id <APCTermsAndConditionsViewControllerDelegate> delegate;

- (NSString *)prepareContent;

- (IBAction)agree:(id)sender;

- (IBAction)close:(id)sender;

@end


@protocol APCTermsAndConditionsViewControllerDelegate <NSObject>

- (void)termsAndConditionsViewControllerDidAgree;

- (void)termsAndConditionsViewControllerDidCancel;

@end
