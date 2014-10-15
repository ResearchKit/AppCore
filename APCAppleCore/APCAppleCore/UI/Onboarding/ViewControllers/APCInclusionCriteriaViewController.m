//
//  APCInclusionCriteriaViewController.m
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 10/14/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCInclusionCriteriaViewController.h"
#import "APCAppleCore.h"

@implementation APCInclusionCriteriaViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addNavigationItems];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];

}

- (void) addNavigationItems {
    self.title = NSLocalizedString(@"Eligibility", @"");
    
    UIBarButtonItem *nextBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Next", @"") style:UIBarButtonItemStylePlain target:self action:@selector(next)];
    nextBarButton.enabled = [self isContentValid];
    self.navigationItem.rightBarButtonItem = nextBarButton;
}

/*********************************************************************************/
#pragma mark - Abstract Implementations
/*********************************************************************************/
- (void) next {}
- (BOOL) isContentValid { return NO;}


@end
