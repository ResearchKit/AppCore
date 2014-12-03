// 
//  APCEmailVerifyViewController.h 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import <UIKit/UIKit.h>

@interface APCEmailVerifyViewController : UIViewController


@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;

@property (weak, nonatomic) IBOutlet UILabel *topMessageLabel;

@property (weak, nonatomic) IBOutlet UILabel *emailLabel;

@property (weak, nonatomic) IBOutlet UILabel *middleMessageLabel;

@property (weak, nonatomic) IBOutlet UILabel *bottomMessageLabel;

@property (weak, nonatomic) IBOutlet UIButton *changeEmailButton;

- (IBAction)changeEmailAddress:(id)sender;

@end
