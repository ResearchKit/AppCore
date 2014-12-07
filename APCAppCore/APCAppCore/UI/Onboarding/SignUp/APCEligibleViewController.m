// 
//  APCEligibleViewController.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "APCEligibleViewController.h"
#import "APCAppCore.h"

@interface APCEligibleViewController () <RKSTTaskViewControllerDelegate>

@end

@implementation APCEligibleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setUpAppearance];
    [self setupNavAppearance];
    
    [self.logoImageView setImage:[UIImage imageNamed:@"logo_disease"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setUpAppearance
{
    self.label1.font = [UIFont appRegularFontWithSize:19.0f];
    self.label1.textColor = [UIColor appSecondaryColor1];
    
    self.label2.font = [UIFont appLightFontWithSize:19.0];
    self.label2.textColor = [UIColor appSecondaryColor2];
    
    [self.consentButton setBackgroundImage:[UIImage imageWithColor:[UIColor appPrimaryColor]] forState:UIControlStateNormal];
    [self.consentButton setTitleColor:[UIColor appSecondaryColor4] forState:UIControlStateNormal];
}

- (void)setupNavAppearance
{
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 0, 44, 44);
    [backButton setImage:[[UIImage imageNamed:@"back_button"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    backButton.tintColor = [UIColor appPrimaryColor];
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [self.navigationItem setLeftBarButtonItem:backBarButton];
}

- (APCOnboarding *)onboarding
{
    return ((APCAppDelegate *)[UIApplication sharedApplication].delegate).onboarding;
}

- (APCUser *) user {
    return ((APCAppDelegate*) [UIApplication sharedApplication].delegate).dataSubstrate.currentUser;;
}


- (void)showConsent
{
    RKSTTaskViewController *consentVC = [((APCAppDelegate *)[UIApplication sharedApplication].delegate) consentViewController];
    
    consentVC.taskDelegate = self;
    [self presentViewController:consentVC animated:YES completion:nil];
    
}


#pragma mark - RKSTTaskViewControllerDelegate methods

- (void)taskViewControllerDidComplete: (RKSTTaskViewController *)taskViewController
{
    RKSTConsentSignatureResult *consentResult = (RKSTConsentSignatureResult *)[[taskViewController.result.results[1] results] firstObject];
    
    APCUser *user = [self user];
    user.consentSignatureName = consentResult.signature.name;
    user.consentSignatureImage = UIImagePNGRepresentation(consentResult.signature.signatureImage);
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = consentResult.signature.signatureDateFormatString;
    user.consentSignatureDate = [dateFormatter dateFromString:consentResult.signature.signatureDate];
    
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        [((APCAppDelegate*)[UIApplication sharedApplication].delegate) dataSubstrate].currentUser.userConsented = YES;
        
        [self startSignUp];
    }];
}

- (void)taskViewControllerDidCancel:(RKSTTaskViewController *)taskViewController
{
    [taskViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)taskViewController:(RKSTTaskViewController *)taskViewController didFailOnStep:(RKSTStep *)step withError:(NSError *)error
{
    //TODO: Figure out what to do if it fails
    [taskViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Selectors

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
    
    [[self onboarding] popScene];
}

- (void) startSignUp
{
    UIViewController *viewController = [[self onboarding] nextScene];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)startConsentTapped:(id)sender
{
#if DEVELOPMENT
    [self startSignUp];
#else
    if (((APCAppDelegate*)[UIApplication sharedApplication].delegate).dataSubstrate.parameters.hideConsent)
    {
        [self startSignUp];
    }
    else
    {
        [self showConsent];
    }
#endif
}

@end
