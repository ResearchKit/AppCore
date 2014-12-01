//
//  APCEligibleViewController.m
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 10/15/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCEligibleViewController.h"
#import "APCAppleCore.h"

@interface APCEligibleViewController () <RKSTTaskViewControllerDelegate>

@end

@implementation APCEligibleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setUpAppearance];
    [self setupNavAppearance];
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

- (void)showConsent
{
    RKSTConsentDocument* consent = [[RKSTConsentDocument alloc] init];
    consent.title = @"Demo Consent";
    consent.signaturePageTitle = @"Consent";
    consent.signaturePageContent = @"I agree  to participate in this research Study.";
    
    //TODO:Check the identifier
    RKSTConsentSignature *participantSig = [RKSTConsentSignature signatureForPersonWithTitle:@"Participant" dateFormatString:@"yyyy-MM-dd 'at' HH:mm" identifier:@"com.ymedia.participant"];
    [consent addSignature:participantSig];
    
    RKSTConsentSignature *investigatorSig = [RKSTConsentSignature signatureForPersonWithTitle:@"Investigator" dateFormatString:@"yyyy-MM-dd 'at' HH:mm" identifier:@"com.ymedia.participant"];
    [consent addSignature:investigatorSig];
    
    
    
    
    NSMutableArray* components = [NSMutableArray new];
    
    NSArray* scenes = @[@(RKSTConsentSectionTypeOverview),
                        @(RKSTConsentSectionTypeActivity),
                        @(RKSTConsentSectionTypeSensorData),
                        @(RKSTConsentSectionTypeDeIdentification),
                        @(RKSTConsentSectionTypeCombiningData),
                        @(RKSTConsentSectionTypeUtilizingData),
                        @(RKSTConsentSectionTypeImpactLifeTime),
                        @(RKSTConsentSectionTypePotentialRiskUncomfortableQuestion),
                        @(RKSTConsentSectionTypePotentialRiskSocial),
                        @(RKSTConsentSectionTypeAllowWithdraw)];
    for (NSNumber* type in scenes) {
        RKSTConsentSection* c = [[RKSTConsentSection alloc] initWithType:type.integerValue];
        c.content = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam adhuc, meo fortasse vitio, quid ego quaeram non perspicis. Plane idem, inquit, et maxima quidem, qua fieri nulla maior potest. Quonam, inquit, modo? An potest, inquit ille, quicquam esse suavius quam nihil dolere? Cave putes quicquam esse verius. Quonam, inquit, modo?";
        [components addObject:c];
    }
    
    {
        RKSTConsentSection* c = [[RKSTConsentSection alloc] initWithType:RKSTConsentSectionTypeOnlyInDocument];
        c.summary = @"OnlyInDocument Scene summary";
        c.title = @"OnlyInDocument Scene";
        c.content = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam adhuc, meo fortasse vitio, quid ego quaeram non perspicis. Plane idem, inquit, et maxima quidem, qua fieri nulla maior potest. Quonam, inquit, modo? An potest, inquit ille, quicquam esse suavius quam nihil dolere? Cave putes quicquam esse verius. Quonam, inquit, modo?";
        [components addObject:c];
    }
    
    consent.sections = [components copy];
    
    RKSTVisualConsentStep *step = [[RKSTVisualConsentStep alloc] initWithDocument:consent];
    RKSTConsentReviewStep *reviewStep = [[RKSTConsentReviewStep alloc] initWithSignature:participantSig inDocument:consent];
    RKSTOrderedTask *task = [[RKSTOrderedTask alloc] initWithIdentifier:@"consent" steps:@[step,reviewStep]];
    RKSTTaskViewController *consentVC = [[RKSTTaskViewController alloc] initWithTask:task taskRunUUID:[NSUUID UUID]];
    
    consentVC.taskDelegate = self;
    [self presentViewController:consentVC animated:YES completion:nil];
    
}


#pragma mark - TaskViewController Delegate methods

- (void)taskViewControllerDidComplete: (RKSTTaskViewController *)taskViewController
{
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
