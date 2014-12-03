// 
//  APCIntroVideoViewController.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "APCIntroVideoViewController.h"
#import "APCStudyOverviewViewController.h"
#import "NSBundle+Helper.h"

static NSString *const kVideoShownKey = @"VideoShown";

@interface APCIntroVideoViewController ()

@end

@implementation APCIntroVideoViewController

#pragma mark - Init

- (instancetype) initWithContentURL:(NSURL *)contentURL {
    self = [super initWithContentURL:contentURL];
    if (self) {
        self.moviePlayer.controlStyle = MPMovieControlStyleNone;
    }
    
    return self;
}

#pragma mark - Life Cycle

- (void) viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(CGRectGetWidth(self.view.frame) - 70, 10, 60, 44);
    [button setTitle:NSLocalizedString(@"Skip", @"") forState:UIControlStateNormal];
    [button addTarget:self action:@selector(skip) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:button];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    [self.moviePlayer play];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    self.moviePlayer.scalingMode = MPMovieScalingModeAspectFill;
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Notifications

- (void) playbackDidFinish:(NSNotification*)notification {
    int reason = [[[notification userInfo] valueForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
    if (reason == MPMovieFinishReasonPlaybackEnded) {
        [self skip];
    }
}


#pragma mark - Public Methods

- (void) skip {
    APCStudyOverviewViewController * vc = [[UIStoryboard storyboardWithName:@"APCOnboarding" bundle:[NSBundle appleCoreBundle]] instantiateViewControllerWithIdentifier:@"StudyOverviewVC"];
    [self.navigationController pushViewController:vc animated:YES];
}
@end
