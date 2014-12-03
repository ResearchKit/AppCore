//
//  APCEligibleViewController.h
//  APCAppCore
//
//  Created by Dhanush Balachandran on 10/15/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface APCEligibleViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *label1;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UILabel *label2;
@property (weak, nonatomic) IBOutlet UIButton *consentButton;

- (void) showConsent;
- (void) startSignUp;
@end
