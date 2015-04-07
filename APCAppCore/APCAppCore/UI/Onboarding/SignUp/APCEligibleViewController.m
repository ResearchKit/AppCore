// 
//  APCEligibleViewController.m 
//  APCAppCore 
// 
// Copyright (c) 2015, Apple Inc. All rights reserved. 
// 
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
// 
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
// 
// 2.  Redistributions in binary form must reproduce the above copyright notice, 
// this list of conditions and the following disclaimer in the documentation and/or 
// other materials provided with the distribution. 
// 
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors 
// may be used to endorse or promote products derived from this software without 
// specific prior written permission. No license is granted to the trademarks of 
// the copyright holders even if such marks are included in this software. 
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE 
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
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

- (void)goBack
{

}

- (void)taskViewController:(ORKTaskViewController *) __unused taskViewController stepViewControllerWillAppear:(ORKStepViewController *) __unused stepViewController
{

}

- (void)taskViewController:(ORKTaskViewController *)taskViewController didFinishWithReason:(ORKTaskViewControllerFinishReason)reason error:(nullable NSError *)__unused error
{
    if (reason == ORKTaskViewControllerFinishReasonCompleted)
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
        if (consentResult != nil && consentResult.signature.requiresName && (consentResult.signature.givenName && consentResult.signature.familyName))
        {
            APCUser *user = [self user];
            user.consentSignatureName = [consentResult.signature.givenName stringByAppendingFormat:@" %@",consentResult.signature.familyName];
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
            [[NSNotificationCenter defaultCenter] postNotificationName:APCConsentCompletedWithDisagreeNotification object:nil];
            [taskViewController dismissViewControllerAnimated:YES completion:nil];
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
