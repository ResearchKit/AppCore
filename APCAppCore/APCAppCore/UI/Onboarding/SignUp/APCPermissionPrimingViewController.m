//
//  APCPermissionPrimingViewController.m
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCPermissionPrimingViewController.h"
#import "UIFont+APCAppearance.h"
#import "UIColor+APCAppearance.h"
#import "APCAppDelegate.h"
#import "APCCustomBackButton.h"

@interface APCPermissionPrimingViewController ()

@end

@implementation APCPermissionPrimingViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupAppearance];
    [self setupNavAppearance];
    
    self.title = NSLocalizedString(@"Consent", @"Consent");
    
    self.titleLabel.text = NSLocalizedString(@"What to Expect", @"What to Expect");
    
    NSDictionary *initialOptions = ((APCAppDelegate *)[UIApplication sharedApplication].delegate).initializationOptions;
    NSDictionary *servicesDescrtiptions = initialOptions[kAppServicesDescriptionsKey];
    self.detailTextLabel.text = servicesDescrtiptions[@(kSignUpPermissionsTypeHealthKit)];
}

- (void)setupAppearance
{
    self.titleLabel.font = [UIFont appLightFontWithSize:38.0f];
    self.titleLabel.textColor = [UIColor appSecondaryColor1];
    
    self.detailTextLabel.font = [UIFont appRegularFontWithSize:16.0f];
    self.detailTextLabel.textColor = [UIColor appSecondaryColor1];
    
    self.headerImageView.image = [UIImage imageNamed:@"switch_icon"];
}

- (void)setupNavAppearance
{
    UIBarButtonItem  *backster = [APCCustomBackButton customBackBarButtonItemWithTarget:self action:@selector(back) tintColor:[UIColor appPrimaryColor]];
    [self.navigationItem setLeftBarButtonItem:backster];
    
}

- (APCOnboarding *)onboarding
{
    return ((APCAppDelegate *)[UIApplication sharedApplication].delegate).onboarding;
}

- (IBAction)next:(id)sender
{
    UIViewController *viewController = [[self onboarding] nextScene];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)back
{
    [[self onboarding] popScene];
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
