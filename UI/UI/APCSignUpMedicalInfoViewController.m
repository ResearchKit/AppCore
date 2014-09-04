//
//  SignUpMedicalInfoViewController.m
//  UI
//
//  Created by Karthik Keyan on 9/2/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCStepProgressBar.h"
#import "APCSignupTouchIDViewController.h"
#import "APCSignUpMedicalInfoViewController.h"

@interface APCSignUpMedicalInfoViewController ()

@end

@implementation APCSignUpMedicalInfoViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.fields = @[@(UserInfoFieldMedicalCondition), @(UserInfoFieldMedication), @(UserInfoFieldBloodType), @(UserInfoFieldWeight), @(UserInfoFieldHeight)];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableHeaderView = nil;
    
    [self addNavigationItems];
    [self setupProgressBar];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.stepProgressBar setCompletedSteps:1 animation:YES];
}

- (void) addNavigationItems {
    self.title = NSLocalizedString(@"Sign Up", @"");
    
    UIBarButtonItem *nextBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Next", @"") style:UIBarButtonItemStylePlain target:self action:@selector(next)];
    self.navigationItem.rightBarButtonItem = nextBarButton;
}

- (void) setupProgressBar {
    self.stepProgressBar.rightLabel.text = NSLocalizedString(@"optional", @"");
    [self setStepNumber:2 title:NSLocalizedString(@"Medical Information", @"")];
}


#pragma mark - Private Methods

- (void) next {
    APCSignupTouchIDViewController *touchIDViewController = [[APCSignupTouchIDViewController alloc] initWithNibName:@"APCSignupTouchIDViewController" bundle:nil];
    [self.navigationController pushViewController:touchIDViewController animated:YES];
}

@end
