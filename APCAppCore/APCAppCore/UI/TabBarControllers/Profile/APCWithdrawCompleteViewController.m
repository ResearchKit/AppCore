// 
//  APCWithdrawCompleteViewController.m 
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//
 
#import "APCWithdrawCompleteViewController.h"
#import "APCAppCore.h"
#import "UIColor+APCAppearance.h"
#import "UIFont+APCAppearance.h"
#import "UIImage+APCHelper.h"
#import "APCWithdrawSurveyViewController.h"
#import "APCUser+Bridge.h"

@interface APCWithdrawCompleteViewController ()

@end

@implementation APCWithdrawCompleteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupAppearance];
    
    self.navigationItem.hidesBackButton = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
  APCLogViewControllerAppeared();
}

- (void)setupAppearance
{
    [self.messageLabel setTextColor:[UIColor appSecondaryColor1]];
    [self.messageLabel setFont:[UIFont appRegularFontWithSize:19.0]];
    
    [self.surveyLabel setTextColor:[UIColor appSecondaryColor1]];
    [self.surveyLabel setFont:[UIFont appLightFontWithSize:17.0]];
    
    [self.logoImageVIew setImage:[UIImage imageNamed:@"logo_disease"]];
}

- (APCUser *) user {
    return ((APCAppDelegate *)[UIApplication sharedApplication].delegate).dataSubstrate.currentUser;
}

- (IBAction) takeSurvey: (id) __unused sender
{
    APCWithdrawSurveyViewController *viewController = [[UIStoryboard storyboardWithName:@"APCProfile" bundle:[NSBundle appleCoreBundle]] instantiateViewControllerWithIdentifier:@"APCWithdrawSurveyViewController"];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction) noThanks: (id) __unused sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
@end
