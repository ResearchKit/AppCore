// 
//  APCChangePasscodeViewController.h 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import <UIKit/UIKit.h>
#import "APCPasscodeView.h"

@interface APCChangePasscodeViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet APCPasscodeView *passcodeView;

- (IBAction)cancel:(id)sender;
@end
