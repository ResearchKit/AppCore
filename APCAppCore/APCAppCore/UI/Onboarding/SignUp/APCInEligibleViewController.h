//
//  APCInEligibleViewController.h
//  APCAppCore
//
//  Created by Dhanush Balachandran on 10/16/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface APCInEligibleViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UILabel *label;

- (IBAction)next:(id)sender;
@end
