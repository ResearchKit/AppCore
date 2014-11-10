//
//  APCSettingsViewController.h
//  APCAppleCore
//
//  Created by Ramsundar Shandilya on 11/1/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APCPasscodeView.h"

@interface APCChangePasscodeViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet APCPasscodeView *passcodeView;

- (IBAction)cancel:(id)sender;
@end
