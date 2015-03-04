// 
//  APCInclusionCriteriaViewController.m 
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
//
 
#import "APCInclusionCriteriaViewController.h"
#import "APCAppCore.h"

@implementation APCInclusionCriteriaViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupNavAppearance];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
  APCLogViewControllerAppeared();

}

- (void)setupNavAppearance
{
    self.title = NSLocalizedString(@"Eligibility", @"");
    
    UIBarButtonItem *nextBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Next", @"") style:UIBarButtonItemStylePlain target:self action:@selector(next)];
    nextBarButton.enabled = [self isContentValid];
    self.navigationItem.rightBarButtonItem = nextBarButton;
    
    UIBarButtonItem  *backster = [APCCustomBackButton customBackBarButtonItemWithTarget:self action:@selector(back) tintColor:[UIColor appPrimaryColor]];
    [self.navigationItem setLeftBarButtonItem:backster];
}

- (APCOnboarding *)onboarding
{
    return ((APCAppDelegate *)[UIApplication sharedApplication].delegate).onboarding;
}

/*********************************************************************************/
#pragma mark - Abstract Implementations
/*********************************************************************************/
- (void) next {}
- (BOOL) isContentValid { return NO;}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
    
    [[self onboarding] popScene];
}


@end
