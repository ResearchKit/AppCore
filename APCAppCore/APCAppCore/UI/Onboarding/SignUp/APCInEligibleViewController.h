// 
//  APCInEligibleViewController.h 
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
//
 
#import <UIKit/UIKit.h>

@interface APCInEligibleViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UILabel *label;

- (IBAction)next:(id)sender;
@end
