// 
//  APCEmailVerifyViewController.m 
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
 
#import "APCEmailVerifyViewController.h"
#import "APCAppDelegate.h"
#import "UIAlertController+Helper.h"
#import "APCUser+Bridge.h"
#import "UIFont+APCAppearance.h"
#import "UIColor+APCAppearance.h"
#import "NSError+APCAdditions.h"
#import "APCAppCore.h"
#import "APCThankYouViewController.h"


typedef void (^APCStuffToDoAfterSpinnerAppears) (void);
typedef void (^APCAlertDismisser) (void);


/**
 This string appears in a certain text field in the Storyboard.
 We'll replace it with the name of the actual app.  This lets us
 lay out the text in Interface Builder, but still have
 programmatic control over part of it.
 
 We may also use this string in an alert we show the user.
 */
static NSString * const kAPCAppNamePlaceholderString = @"$appName$";

/**
 Text of an alert shown if the user taps the button and
 we think she hasn't clicked that email link yet.
 */
static NSString * const kAPCPleaseClickEmailAlertTitle = @"Please Check Your Email";
static NSString * const kAPCPleaseClickEmailAlertMessageFormatString = @"\nYour email address has not yet been verified.\n\nPlease check your email for a message from $appName$, and click the link in that message.";
static NSString * const kAPCPleaseCheckEmailAlertOkButton = @"OK";


@interface APCEmailVerifyViewController ()
@property (nonatomic, readonly) APCUser * user;
@property (nonatomic, strong) UIAlertController *pleaseCheckEmailAlert;
@property (nonatomic, weak) IBOutlet UIView *spinnerView;
@end


@implementation APCEmailVerifyViewController



// ---------------------------------------------------------
#pragma mark - Who are we talkin' about?
// ---------------------------------------------------------

- (APCUser *)user
{
    return ((APCAppDelegate*) [UIApplication sharedApplication].delegate).dataSubstrate.currentUser;
}



// ---------------------------------------------------------
#pragma mark - View lifecycle methods
// ---------------------------------------------------------

- (void) viewDidLoad
{
    [super viewDidLoad];

    [self setupAppearance];

    self.title = NSLocalizedString(@"Email Verification", nil);
    self.pleaseCheckEmailAlert = nil;

    // Hide the "johnny appleseed@..."
    self.emailLabel.text = self.user.email;

    // Hide the spinner view.  It was probably showing in
    // Interface Builder.
    [self hideSpinnerUsingAnimation: NO andThenDoThis: nil];

    NSString *appName = [APCUtilities appName];
    self.topMessageLabel.text = [self.topMessageLabel.text stringByReplacingOccurrencesOfString: kAPCAppNamePlaceholderString withString: appName];
}

- (void) viewDidAppear: (BOOL) animated
{
    [super viewDidAppear:animated];

    APCLogViewControllerAppeared();
    self.emailLabel.text = self.user.email;
}

- (void) viewWillDisappear:(BOOL)animated
{
    // Hide/cancel all the modal views which might be showing.
    [self cancelPleaseCheckEmailAlertUsingAnimation: NO];
    [self hideSpinnerUsingAnimation: NO andThenDoThis: nil];

    [super viewWillDisappear: animated];
}

- (void)setupAppearance
{
    [self.logoImageView setImage:[UIImage imageNamed:@"logo_disease"]];
    
    [self.topMessageLabel setFont:[UIFont appRegularFontWithSize:17.0f]];
    [self.topMessageLabel setTextColor:[UIColor appSecondaryColor1]];
    
    [self.emailLabel setFont:[UIFont appMediumFontWithSize:16.0f]];
    [self.emailLabel setAdjustsFontSizeToFitWidth:YES];
    [self.emailLabel setTextColor:[UIColor appSecondaryColor1]];
    
    [self.middleMessageLabel setFont:[UIFont appRegularFontWithSize:17.0f]];
    [self.middleMessageLabel setTextColor:[UIColor appSecondaryColor1]];
    
    [self.bottomMessageLabel setFont:[UIFont appRegularFontWithSize:14.0f]];
    [self.bottomMessageLabel setTextColor:[UIColor appSecondaryColor3]];
    
    [self.changeEmailButton.titleLabel setFont:[UIFont appRegularFontWithSize:12.0f]];
    [self.changeEmailButton setTitleColor:[UIColor appPrimaryColor] forState:UIControlStateNormal];
    
    [self.resendEmailButton.titleLabel setFont:[UIFont appRegularFontWithSize:16.0f]];
    [self.resendEmailButton setTitleColor:[UIColor appPrimaryColor] forState:UIControlStateNormal];
}



// ---------------------------------------------------------
#pragma mark - Checking for Sign-In
// ---------------------------------------------------------

- (void) checkSignInOnce
{
    APCLogEventWithData (kNetworkEvent, @{ @"event_detail" : @"Email verification: checking with Sage to see if user has clicked email-verification link." });


    //
    // This call to "user" is the actual signin process.
    //

    __weak APCEmailVerifyViewController * weakSelf = self;

    [self.user signInOnCompletion: ^(NSError *error) {

        [weakSelf handleSigninResponseWithError: error];

    }];
}

/**
 We're on some random background thread.  That's probably ok,
 but keep an eye out for issues.
 */
- (void) handleSigninResponseWithError: (NSError *) error
{
    if (error)
    {
        if (error.code == kSBBServerPreconditionNotMet)
        {
            [self getServerConsent];
        }

        else if (error.code == kAPCSigninErrorCode_NotSignedIn)
        {
            [self showPleaseCheckEmailAlert];
        }

        else
        {
            [self showSignInError: error];
        }
    }
    else
    {
        [self.user updateProfileOnCompletion: ^(NSError *error) {
            APCLogError2 (error);
        }];

        [self showThankYouPage];
    }
}



// ---------------------------------------------------------
#pragma mark - The "Tap to Continue" button
// ---------------------------------------------------------

- (IBAction) tapToContinueButtonWasIndeedTapped: (id) __unused sender
{
    [self showSpinnerAndThenDoThis: ^{
        [self checkSignInOnce];
    }];
}



// ---------------------------------------------------------
#pragma mark - The Spinner
// ---------------------------------------------------------

- (void) showSpinnerAndThenDoThis: (APCStuffToDoAfterSpinnerAppears) callbackBlock
{
    self.spinnerView.alpha = 0;
    self.spinnerView.hidden = NO;

    [UIView animateWithDuration: 0.5
                     animations: ^{

                         self.spinnerView.alpha = 1;

                     } completion: ^(BOOL __unused finished) {

                         // Conceptually, this callback needs to go on
                         // the main thread (even though we're probably
                         // not gonna do a main-thread thing with it).
                         // However, since we're currently in an *animation*
                         // completion block, and this is iOS, we're guaranteed
                         // to already be on the main thread.  So we can
                         // just call it.

                         if (callbackBlock != nil)
                         {
                             callbackBlock ();
                         }
                     }];
}

- (void) hideSpinnerUsingAnimation: (BOOL) shouldAnimate
                     andThenDoThis: (APCStuffToDoAfterSpinnerAppears) callbackBlock
{
    if (shouldAnimate)
    {
        [UIView animateWithDuration: 0.5
                         animations: ^{

                             self.spinnerView.alpha = 0;

                         } completion: ^(BOOL __unused finished) {

                             self.spinnerView.hidden = YES;

                             // See matching comment in -showSpinner.
                             callbackBlock ();
                         }];
    }
    else
    {
        self.spinnerView.hidden = YES;

        if (callbackBlock != nil)
        {
            callbackBlock ();
        }
    }
}



// ---------------------------------------------------------
#pragma mark - Other views we're showing
// ---------------------------------------------------------

/*
 All these methods hide the spinner before displaying the views
 they're designed to display.
 */

- (void) showPleaseCheckEmailAlert
{
    [self hideSpinnerUsingAnimation: YES andThenDoThis:^{

        NSString *message = [kAPCPleaseClickEmailAlertMessageFormatString stringByReplacingOccurrencesOfString: kAPCAppNamePlaceholderString
                                                                                                    withString: [APCUtilities appName]];

        self.pleaseCheckEmailAlert = [UIAlertController alertControllerWithTitle: kAPCPleaseClickEmailAlertTitle
                                                                         message: message
                                                                  preferredStyle: UIAlertControllerStyleAlert];

        UIAlertAction *okayAction = [UIAlertAction actionWithTitle: kAPCPleaseCheckEmailAlertOkButton
                                                             style: UIAlertActionStyleDefault
                                                           handler: ^(UIAlertAction * __unused action)
                                     {
                                         [self cancelPleaseCheckEmailAlertUsingAnimation: YES];
                                     }];

        [self.pleaseCheckEmailAlert addAction: okayAction];

        [self presentViewController: self.pleaseCheckEmailAlert
                           animated: YES
                         completion: nil];
    }];
}

- (void) showConsentError: (NSError *) error
{
    APCLogError2(error);

    [self hideSpinnerUsingAnimation: YES andThenDoThis:^{

        UIAlertController *alert = [UIAlertController simpleAlertWithTitle:NSLocalizedString(@"User Consent Error", @"") message:error.localizedDescription];

        [self presentViewController:alert animated:YES completion:nil];

    }];
}

- (void) showSignInError: (NSError *) error
{
    APCLogError2 (error);

    [self hideSpinnerUsingAnimation: YES andThenDoThis:^{

        UIAlertController *alert = [UIAlertController simpleAlertWithTitle:NSLocalizedString(@"User Sign In Error", @"") message:error.localizedDescription];

        [self presentViewController:alert animated:YES completion:nil];

    }];
}

- (void) showThankYouPage
{
    [self hideSpinnerUsingAnimation: YES andThenDoThis:^{

        // load the thank you view controller
        UIStoryboard *sbOnboarding = [UIStoryboard storyboardWithName:@"APCOnboarding" bundle:[NSBundle appleCoreBundle]];
        APCThankYouViewController *allSetVC = (APCThankYouViewController *)[sbOnboarding instantiateViewControllerWithIdentifier:@"APCThankYouViewController"];

        allSetVC.emailVerified = YES;

        [self presentViewController:allSetVC animated:YES completion:nil];

    }];
}



// ---------------------------------------------------------
#pragma mark - The "please click that link" alert
// ---------------------------------------------------------

- (void) cancelPleaseCheckEmailAlertUsingAnimation: (BOOL) shouldAnimate
{
    __weak APCEmailVerifyViewController *weakSelf = self;

    [self.pleaseCheckEmailAlert dismissViewControllerAnimated: shouldAnimate completion:^{
        weakSelf.pleaseCheckEmailAlert = nil;
    }];
}



// ---------------------------------------------------------
#pragma mark - Handling Consent
// ---------------------------------------------------------

- (void) getServerConsent
{
    __weak APCEmailVerifyViewController * weakSelf = self;

    if (self.user.isUserConsented) {
        [self.user sendUserConsentedToBridgeOnCompletion: ^(NSError *error) {
            [weakSelf handleConsentResponseWithError: error];
        }];
    }
    else
    {
        // What happens here?  And what should?
    }
}

- (void) handleConsentResponseWithError: (NSError *) error
{
    if (error)
    {
        [self showConsentError: error];
    }
    else
    {
        self.user.consented = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:APCUserDidConsentNotification object:nil];

        [self checkSignInOnce];
    }
}



// ---------------------------------------------------------
#pragma mark - Um...  er...  other stuff
// ---------------------------------------------------------

- (IBAction) skip: (id) __unused sender
{
    self.user.signedIn = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:APCUserSignedInNotification object:self];
}

- (IBAction) changeEmailAddress: (id) __unused sender
{
    
}

- (IBAction) secretButton: (id) __unused sender
{
    self.user.signedIn = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:APCUserSignedInNotification object:self];
}

- (IBAction) resendEmail: (id) __unused sender
{
    [self.user resendEmailVerificationOnCompletion:^(NSError *error) {
        if (error != nil) {
            APCLogError2 (error);
        }
     }];
}

@end
