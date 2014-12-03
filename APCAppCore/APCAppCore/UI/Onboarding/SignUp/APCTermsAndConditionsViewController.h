//
//  APCTermsAndConditionsViewController.h
//  APCAppCore
//
//  Created by Ramsundar Shandilya on 10/21/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
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
