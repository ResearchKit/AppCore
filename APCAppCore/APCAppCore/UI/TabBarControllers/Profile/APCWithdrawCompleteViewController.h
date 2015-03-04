//
//  APCWithdrawCompleteViewController.h 
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
//
 
#import <UIKit/UIKit.h>

@interface APCWithdrawCompleteViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UILabel *surveyLabel;

@property (weak, nonatomic) IBOutlet UIImageView *logoImageVIew;

@property (weak, nonatomic) IBOutlet UIButton *takeSurveyButton;
@property (weak, nonatomic) IBOutlet UIButton *noThanksButton;

- (IBAction)takeSurvey:(id)sender;
- (IBAction)noThanks:(id)sender;

@end
