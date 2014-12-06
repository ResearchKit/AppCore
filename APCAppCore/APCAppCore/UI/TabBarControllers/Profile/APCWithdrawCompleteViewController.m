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
#import "UIImage+APCHelper.h"
#import "APCWithdrawSurveyViewController.h"

@interface APCWithdrawCompleteViewController ()

@end

@implementation APCWithdrawCompleteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupAppearance];
    
    self.navigationItem.hidesBackButton = YES;
}

- (void)setupAppearance
{
    [self.messageLabel setTextColor:[UIColor appSecondaryColor1]];
    [self.messageLabel setFont:[UIFont appRegularFontWithSize:19.0]];
    
    [self.surveyLabel setTextColor:[UIColor appSecondaryColor1]];
    [self.surveyLabel setFont:[UIFont appLightFontWithSize:17.0]];
    
    [self.takeSurveyButton setBackgroundImage:[UIImage imageWithColor:[UIColor appPrimaryColor]] forState:UIControlStateNormal];
    [self.takeSurveyButton.titleLabel setFont:[UIFont appMediumFontWithSize:19.0f]];
    
    [self.noThanksButton setTintColor:[UIColor appPrimaryColor]];
    [self.noThanksButton.titleLabel setFont:[UIFont appRegularFontWithSize:17.0f]];
    
    [self.logoImageVIew setImage:[UIImage imageNamed:@"logo_disease"]];
}


- (IBAction)takeSurvey:(id)sender
{
    APCWithdrawSurveyViewController *viewController = [[UIStoryboard storyboardWithName:@"APCProfile" bundle:[NSBundle appleCoreBundle]] instantiateViewControllerWithIdentifier:@"APCWithdrawSurveyViewController"];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)noThanks:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:APCUserLogOutNotification object:self];
}
@end
