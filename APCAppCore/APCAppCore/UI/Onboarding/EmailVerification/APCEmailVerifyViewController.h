// 
//  APCEmailVerifyViewController.h 
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
//
 
#import <UIKit/UIKit.h>

@interface APCEmailVerifyViewController : UIViewController


@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;

@property (weak, nonatomic) IBOutlet UILabel *topMessageLabel;

@property (weak, nonatomic) IBOutlet UILabel *emailLabel;

@property (weak, nonatomic) IBOutlet UILabel *middleMessageLabel;

@property (weak, nonatomic) IBOutlet UILabel *bottomMessageLabel;

@property (weak, nonatomic) IBOutlet UIButton *changeEmailButton;

@property (weak, nonatomic) IBOutlet UIButton *resendEmailButton;

- (IBAction)changeEmailAddress:(id)sender;

@end
