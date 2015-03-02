// 
//  APCEligibleViewController.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "APCEligibleViewController.h"
#import "APCConsentTaskViewController.h"
#import "APCAppCore.h"

static NSString *kreturnControlOfTaskDelegate = @"returnControlOfTaskDelegate";

@interface APCEligibleViewController () <ORKTaskViewControllerDelegate>
@property (strong, nonatomic) ORKTaskViewController *consentVC;
@end

@implementation APCEligibleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(returnControlOfTaskDelegate:) name:kreturnControlOfTaskDelegate object:nil];
    
    [self setUpAppearance];
    [self setupNavAppearance];
    
    [self.logoImageView setImage:[UIImage imageNamed:@"logo_disease"]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
  APCLogViewControllerAppeared();
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kreturnControlOfTaskDelegate object:nil];
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
    UIBarButtonItem  *backster = [APCCustomBackButton customBackBarButtonItemWithTarget:self action:@selector(back) tintColor:[UIColor appPrimaryColor]];
    [self.navigationItem setLeftBarButtonItem:backster];
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
    self.consentVC = [((APCAppDelegate *)[UIApplication sharedApplication].delegate) consentViewController];
    
    self.consentVC.delegate = self;
    self.consentVC.navigationBar.topItem.title = NSLocalizedString(@"Consent", nil);
    
    [self presentViewController:self.consentVC animated:YES completion:nil];
    
}

#pragma mark - ORKTaskViewControllerDelegate methods

//called on notification
-(void)returnControlOfTaskDelegate: (id) __unused sender{
    
    self.consentVC.delegate = self;
    
}

- (void)taskViewController:(ORKTaskViewController *)taskViewController didFinishWithResult:(ORKTaskViewControllerResult)result error:(NSError *) __unused error
{
    if (result == ORKTaskViewControllerResultCompleted)
    {
        ORKConsentSignatureResult *consentResult =  nil;
        
        if ([taskViewController respondsToSelector:@selector(signatureResult)])
        {
            APCConsentTaskViewController *consentTaskViewController = (APCConsentTaskViewController *)taskViewController;
            if (consentTaskViewController.signatureResult)
            {
                consentResult = consentTaskViewController.signatureResult;
            }
        }
        else
        {
            NSString*   signatureResultStepIdentifier = @"reviewStep";
            
            for (ORKStepResult* result in taskViewController.result.results)
            {
                NSLog(@"Id: %@", result.identifier);
                if ([result.identifier isEqualToString:signatureResultStepIdentifier])
                {
                    consentResult = (ORKConsentSignatureResult*)[[result results] firstObject];
                    break;
                }
            }
        }
        
        //  if no signature (no consent result) then assume the user failed the quiz
        if (consentResult != nil && consentResult.signature.requiresName && (consentResult.signature.firstName && consentResult.signature.lastName))
        {
            APCUser *user = [self user];
            user.consentSignatureName = [consentResult.signature.firstName stringByAppendingFormat:@" %@",consentResult.signature.lastName];
            user.consentSignatureImage = UIImagePNGRepresentation(consentResult.signature.signatureImage);
            
            NSDateFormatter *dateFormatter = [NSDateFormatter new];
            dateFormatter.dateFormat = consentResult.signature.signatureDateFormatString;
            user.consentSignatureDate = [dateFormatter dateFromString:consentResult.signature.signatureDate];
            [((APCAppDelegate*)[UIApplication sharedApplication].delegate) dataSubstrate].currentUser.userConsented = YES;
            
            [self.consentVC dismissViewControllerAnimated:YES completion:^
             {
                 [self startSignUp];
             }];
        }
        else
        {
            [taskViewController dismissViewControllerAnimated:YES completion:^{
                 [[NSNotificationCenter defaultCenter] postNotificationName:APCConsentCompletedWithDisagreeNotification object:nil];
             }];
        }
    }
    else
    {
        [taskViewController dismissViewControllerAnimated:YES completion:^{
             [[NSNotificationCenter defaultCenter] postNotificationName:APCConsentCompletedWithDisagreeNotification object:nil];
         }];
    }
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

- (IBAction)startConsentTapped:(id) __unused sender
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
