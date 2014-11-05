//
//  OnBoardingVideoViewController.m
//  OnBoarding
//
//  Created by Karthik Keyan on 9/2/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "UIView+Helper.h"
#import "APCIntroVideoViewController.h"

@interface APCIntroVideoViewController ()

@end

@implementation APCIntroVideoViewController

#pragma mark - Init

- (instancetype) initWithContentURL:(NSURL *)contentURL {
    self = [super initWithContentURL:contentURL];
    if (self) {
        self.moviePlayer.controlStyle = MPMovieControlStyleDefault;
    }
    
    return self;
}

#pragma mark - Life Cycle

- (void) viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(self.view.innerWidth - 70, 10, 60, 44);
    [button setTitle:NSLocalizedString(@"Skip", @"") forState:UIControlStateNormal];
    [button addTarget:self action:@selector(skip) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    
    [self.moviePlayer play];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    

    [self.moviePlayer setControlStyle:MPMovieControlStyleNone];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    
    [self.moviePlayer pause];
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
}

@end
