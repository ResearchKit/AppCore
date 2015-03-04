//
//  APCDashboardMoreInfoViewController.h
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APCButton.h"

@interface APCDashboardMoreInfoViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet APCButton *dismissButton;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewCenterYConstraint;

@property (strong, nonatomic) NSString *titleString;
@property (strong, nonatomic) NSString *info;
@property (strong, nonatomic) UIImage *blurredImage;


- (IBAction)dismiss:(id)sender;

@end
