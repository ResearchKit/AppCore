//
//  SignUpMedicalInfoViewController.m
//  UI
//
//  Created by Karthik Keyan on 9/2/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCStepProgressBar.h"
#import "UITableView+AppearanceCategory.h"
#import "APCSignupTouchIDViewController.h"
#import "APHSignUpMedicalInfoViewController.h"

@interface APHSignUpMedicalInfoViewController ()

@end

@implementation APHSignUpMedicalInfoViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.fields = @[@(APCUserInfoFieldMedicalCondition), @(APCUserInfoFieldMedication), @(APCUserInfoFieldBloodType), @(APCUserInfoFieldHeight), @(APCUserInfoFieldWeight)];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableHeaderView = nil;
    
    [self addNavigationItems];
    [self setupProgressBar];
    [self addFooterView];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.stepProgressBar setCompletedSteps:1 animation:YES];
}

- (void) addNavigationItems {
    self.title = NSLocalizedString(@"Medical Information", @"");
    
    UIBarButtonItem *nextBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Next", @"") style:UIBarButtonItemStylePlain target:self action:@selector(next)];
    self.navigationItem.rightBarButtonItem = nextBarButton;
}

- (void) setupProgressBar {
    self.stepProgressBar.rightLabel.text = NSLocalizedString(@"optional", @"");
}

- (void) addFooterView {
    UILabel *label = [UILabel new];
    label.frame = CGRectMake(0, 0, self.tableView.frame.size.width, 44);
    label.font = [UITableView footerFont];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UITableView footerTextColor];
    label.text = NSLocalizedString(@"All fields on this screen are optional.", @"");
    self.tableView.tableFooterView = label;
}


#pragma mark - Private Methods

- (void) next {
    APCSignupTouchIDViewController *touchIDViewController = [[APCSignupTouchIDViewController alloc] initWithNibName:@"APCSignupTouchIDViewController" bundle:nil];
    [self.navigationController pushViewController:touchIDViewController animated:YES];
}

@end
