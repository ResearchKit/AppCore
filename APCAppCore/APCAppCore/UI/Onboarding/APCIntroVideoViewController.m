// 
//  APCIntroVideoViewController.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "APCIntroVideoViewController.h"
#import "APCStudyOverviewViewController.h"
#import "NSBundle+Helper.h"
#import "APCAppCore.h"

static NSString *const kVideoShownKey = @"VideoShown";

@interface APCIntroVideoViewController ()

@end

@implementation APCIntroVideoViewController

#pragma mark - Init

- (instancetype) initWithContentURL:(NSURL *)contentURL {
    self = [super initWithContentURL:contentURL];
    if (self) {
        self.moviePlayer.controlStyle = MPMovieControlStyleFullscreen;
    }
    
    return self;
}

#pragma mark - Life Cycle

- (void) viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    [self.moviePlayer play];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
  APCLogViewControllerAppeared();
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    
    [self.moviePlayer pause];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kVideoShownKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

#pragma mark - Notifications

- (void) playbackDidFinish:(NSNotification*)notification {
    int reason = [[[notification userInfo] valueForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
    if (reason == MPMovieFinishReasonPlaybackEnded || reason == MPMovieFinishReasonUserExited) {
        [self dismiss];
    }
}


#pragma mark - Public Methods

- (void) dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
