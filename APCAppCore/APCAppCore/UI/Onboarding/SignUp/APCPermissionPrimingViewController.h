//
//  APCPermissionPrimingViewController.h
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APCButton.h"

@interface APCPermissionPrimingViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailTextLabel;
@property (weak, nonatomic) IBOutlet APCButton *nextButton;

- (IBAction)next:(id)sender;

@end
