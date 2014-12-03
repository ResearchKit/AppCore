// 
//  APCWithdrawCompleteViewController.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "APCWithdrawCompleteViewController.h"
#import "APCAppCore.h"
#import "UIColor+APCAppearance.h"
#import "UIFont+APCAppearance.h"

@interface APCWithdrawCompleteViewController ()

@end

@implementation APCWithdrawCompleteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupAppearance];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupAppearance
{
    [self.messageLabel setTextColor:[UIColor appSecondaryColor1]];
    [self.messageLabel setFont:[UIFont appRegularFontWithSize:19.0]];
}

- (IBAction)withdrawComplete:(id)sender
{
    //TODO: Temporary function. Implement withdrawal.
    [[NSNotificationCenter defaultCenter] postNotificationName:APCUserLogOutNotification object:self];
}
@end
