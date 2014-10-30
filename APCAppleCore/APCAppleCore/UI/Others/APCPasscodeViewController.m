//
//  APCPasscodeViewController.m
//  APCAppleCore
//
//  Created by Ramsundar Shandilya on 10/22/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCPasscodeViewController.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import "UIAlertView+Helper.h"

@interface APCPasscodeViewController ()

@property (nonatomic, strong) LAContext *touchContext;

@end

@implementation APCPasscodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.touchContext = [LAContext new];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)useTouchId:(id)sender
{
    NSError *error = nil;
    
    if ([self.touchContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        self.touchContext.localizedFallbackTitle = NSLocalizedString(@"Enter Passcode", @"");
        
        NSString *localizedReason = NSLocalizedString(@"Please authenticate with Touch ID", @"");
        
        typeof(self) __weak weakSelf = self;
        [self.touchContext evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                          localizedReason:localizedReason
                                    reply:^(BOOL success, NSError *error) {
                                        
                                        if (success) {
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                [weakSelf dismissViewControllerAnimated:YES completion:nil];
                                            });
                                            
                                        } else {
                                            if (error.code == kLAErrorUserFallback) {
                                                //Passcode
                                            } else if (error.code == kLAErrorUserCancel) {
                                                //cancel
                                            } else {
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    [UIAlertView showSimpleAlertWithTitle:NSLocalizedString(@"Authentication Error", @"") message:NSLocalizedString(@"Failed to authenticate.", @"")];
                                                });
                                            }
                                        }
                                    }];
    }    
}


@end
