//
//  APCEmailVerifyViewController.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "APCEmailVerifyViewController.h"
#import "APCAppDelegate.h"
#import "UIAlertController+Helper.h"
#import "APCUser+Bridge.h"
#import "UIAlertController+Helper.h"
#import "UIFont+APCAppearance.h"
#import "UIColor+APCAppearance.h"
#import "NSError+APCAdditions.h"
#import "APCAppCore.h"

@interface APCEmailVerifyViewController ()
@property (nonatomic, readonly) APCUser * user;
@property (nonatomic, assign) NSUInteger signInCounter;
@property (nonatomic, strong) NSTimer *timer;
@property (weak, nonatomic) IBOutlet UIButton *tapToRetryAgainButton;
@property (nonatomic, assign) BOOL pleaseStopPulsingTheButton;
@property (weak, nonatomic) IBOutlet UIView *retryButtonContainer;

/** Makes sure we don't queue a server request for 
 every time the user presses the button. */
@property (nonatomic, assign) BOOL serverCheckIsInProgress;
@end


/*
 There are 3 separate timing concepts happening here, so we can
 get a specific, hopefully fluid, user experience.
 
 The goal:  The user sees this screen.  It invites her to check her
 email and click a link in that email.  The next time she comes
 back to this screen, she finds that we have magically detected
 that "click," and have let her into the app.
 
 Here's how we'll make that happen.
 
 1) Every 10 seconds:  check with the server to see if she
    clicked that link.
 
 2) After we check 10 times, stop checking, on the premise
    that she may have left the room and doesn't care any
    more.
 
 3) Show a button on the screen, inviting her to check
    whenever she likes.  When she taps the button, we'll
    go back to step 1.


 Other notes:
 
 -  Everything above has some interesting threading issues.
    I've tried to make them explicit, below.

 -  Those timing and counter values are all constants,
    named "kAPCSignIn...", defined in APCConstants.h.
 
 -  The button is floating inside a container.  The container
    handles the user tap, not the button.  The button
    spends most of its life fading in and out, and the
    user can't tap on it while it's animating.
 
 -  The tap process has a "gate."  Once the user taps, we
    we prevent taps until the next server response has
    come back.  This is to prevent a bunch of network hits,
    and keep us from handling the asynchronous responses,
    if the user taps the button a bunch of times in a row.
 */

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

    self.timer = nil;
    self.signInCounter = 0;
    self.pleaseStopPulsingTheButton = NO;
    self.serverCheckIsInProgress = NO;

    [self setupAppearance];
    
    self.title = NSLocalizedString(@"Email Verification", nil);
    self.emailLabel.text = self.user.email;

    NSString *appName = [APCUtilities appName];
    self.topMessageLabel.text = [NSString stringWithFormat:@"An email has been sent by %@ to", appName];
}

- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];

    // Check the server.  This will check once, and then
    // start a timer to check again in a few seconds.
    [self startPulsingTapToContinueButton];
    [self resetSignInCounter];
    [self checkSignInOnce];
}

- (void) viewDidAppear: (BOOL) animated
{
    [super viewDidAppear:animated];

    APCLogViewControllerAppeared();
    self.emailLabel.text = self.user.email;
}

- (void) viewWillDisappear:(BOOL)animated
{
    [self stopPulsingTapToContinueButton];

    // This is crucial:  without this, we'll get a memory leak
    // (a retain loop).
    [self stopTimer];

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
#pragma mark - The Sign-in Timer and Counter
// ---------------------------------------------------------

- (void) resetSignInCounter
{
    self.signInCounter = 0;
}

- (BOOL) shouldTrySignInAgain
{
    return self.signInCounter <= kAPCSigninNumRetriesBeforePause;
}

- (void) launchTimerOnce
{
    /*
     This waits a few seconds, and calls -timerFired.
     */
    self.timer = [NSTimer scheduledTimerWithTimeInterval: kAPCSigninNumSecondsBetweenRetries
                                                  target: self
                                                selector: @selector(timerFired)
                                                userInfo: nil
                                                 repeats: NO];
}

- (void) stopTimer
{
    /**
     "The timer maintains a strong reference to the target" --
     this view controller -- until the timer is invalidated."
     Argh!  What a perfect way to create a retain loop!
     
     From:
     https://developer.apple.com/library/prerelease/ios/documentation/Cocoa/Reference/Foundation/Classes/NSTimer_Class/index.html#//apple_ref/occ/clm/NSTimer/scheduledTimerWithTimeInterval:invocation:repeats:
     */
    [self.timer invalidate];
    self.timer = nil;
}

- (void) timerFired
{
    [self checkSignInOnce];
}



// ---------------------------------------------------------
#pragma mark - Checking for Sign-In
// ---------------------------------------------------------

- (void) checkSignInOnce
{
    __weak APCEmailVerifyViewController * weakSelf = self;

    self.signInCounter = self.signInCounter + 1;
    self.serverCheckIsInProgress = YES;

    [self announceCheckingServer];

    //
    // This is the signin process itself.
    //
    [self.user signInOnCompletion: ^(NSError *error) {

        self.serverCheckIsInProgress = NO;

        [weakSelf handleSigninResponseWithError: error];

    }];
}

- (void) announceCheckingServer
{
    APCLogEventWithData (kNetworkEvent, @{ @"event_detail" : @"Email verification: checking with Sage to see if user has clicked email-verification link." });
}

- (void) announceTemporarilyStoppingTimerLoop
{
    NSString *message = [NSString stringWithFormat: @"Email verification: Stopping auto-verification check after %d tries.  We'll try again when the user taps the on-screen button.", (int) kAPCSigninNumRetriesBeforePause];

    APCLogEventWithData (kNetworkEvent, @{ @"event_detail" : message });
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
            /*
             Retry 10 times or so.  Then stop.
             The user can start again at any time
             by pressing the button.
             */
            if (self.shouldTrySignInAgain)
            {
                [self launchTimerOnce];
            }
            else
            {
                [self announceTemporarilyStoppingTimerLoop];
            }
        }
        else
        {
            APCLogError2 (error);
            UIAlertController *alert = [UIAlertController simpleAlertWithTitle:NSLocalizedString(@"User Sign In Error", @"") message:error.localizedDescription];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
    else
    {
        self.user.signedIn = YES;

        [self.user updateProfileOnCompletion:^(NSError *error) {
            APCLogError2 (error);
        }];
    }
}



// ---------------------------------------------------------
#pragma mark - The "Tap to Continue" button
// ---------------------------------------------------------

- (void) startPulsingTapToContinueButton
{
    self.pleaseStopPulsingTheButton = NO;
    self.tapToRetryAgainButton.alpha = 0;
    self.tapToRetryAgainButton.hidden = NO;

    [self showTapToContinueButton];
}

- (void) stopPulsingTapToContinueButton
{
    // As soon as the next fade-in or fade-out completes, it'll stop.
    self.pleaseStopPulsingTheButton = YES;
}

- (void) showTapToContinueButton
{
    if (! self.pleaseStopPulsingTheButton)
    {
        [UIView animateWithDuration: kAPCSignInButtonPulseFadeInTimeInSeconds
                         animations: ^{

            self.tapToRetryAgainButton.alpha = 1;

        } completion: ^(BOOL __unused finished) {

            [self hideTapToContinueButton];

        }];
    }
}

- (void) hideTapToContinueButton
{
    if (! self.pleaseStopPulsingTheButton)
    {
        [UIView animateWithDuration: kAPCSignInButtonPulseFadeOutTimeInSeconds
                              delay: kAPCSignInButtonPulsePauseWhileVisibleTimeInSeconds
                            options: 0
                         animations:^{

            self.tapToRetryAgainButton.alpha = 0;

        } completion: ^(BOOL __unused finished) {

            [self showTapToContinueButton];

        }];
    }
}

- (IBAction) tapToContinueGestureWasInvoked: (UIGestureRecognizer *) __unused tapGesture
{
    /*
     When a server check starts, we'll set this flag, and un-set
     it when we get the response.  This ensures we only queue up
     one request, no matter how many times the user taps the
     button.
     */
    if (! self.serverCheckIsInProgress)
    {
        [self stopTimer];
        [self resetSignInCounter];
        [self checkSignInOnce];
    }
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
}

- (void) handleConsentResponseWithError: (NSError *) error
{
    if (error)
    {
        APCLogError2(error);

        UIAlertController *alert = [UIAlertController simpleAlertWithTitle:NSLocalizedString(@"User Consent Error", @"") message:error.localizedDescription];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else
    {
        self.user.consented = YES;
        [self checkSignInOnce];
    }
}



// ---------------------------------------------------------
#pragma mark - Um...  er...  other stuff
// ---------------------------------------------------------

- (IBAction) skip: (id) __unused sender
{
    self.user.signedIn = YES;
}

- (IBAction) changeEmailAddress: (id) __unused sender
{
    
}

- (IBAction) secretButton: (id) __unused sender
{
    self.user.signedIn = YES;
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
