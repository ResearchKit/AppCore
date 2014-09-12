//
//  APCViewController.m
//  UI
//
//  Created by Karthik Keyan on 9/11/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCViewController.h"

@implementation APCViewController

- (void) loadView {
    if (self.nibName) {
        [super loadView];
    }
    else {
        self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        self.view.backgroundColor = [UIColor whiteColor];
    }
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return UIInterfaceOrientationPortrait;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationPortrait | UIInterfaceOrientationLandscapeLeft | UIInterfaceOrientationLandscapeRight;
}

- (UIInterfaceOrientation) preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

@end
