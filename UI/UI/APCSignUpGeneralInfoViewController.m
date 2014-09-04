//
//  SignUpGeneralInfoViewController.m
//  OnBoarding
//
//  Created by Karthik Keyan on 9/2/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCProfile.h"
#import "APCStepProgressBar.h"
#import "APCSignUpGeneralInfoViewController.h"
#import "APCSignUpMedicalInfoViewController.h"

@interface APCSignUpGeneralInfoViewController ()

@property (weak, nonatomic) IBOutlet UIButton *agreeButton;

@end

@implementation APCSignUpGeneralInfoViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.fields = @[@(UserInfoFieldUserName), @(UserInfoFieldEmail), @(UserInfoFieldPassword), @(UserInfoFieldDateOfBirth), @(UserInfoFieldGender)];
        self.profile = [APCProfile new];
    }
    return self;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    
    [self addNavigationItems];
    [self addFooterView];
    [self setupProgressBar];
}


#pragma mark - UI Methods

- (void) addNavigationItems {
    self.title = NSLocalizedString(@"Sign Up", @"");
    
    UIBarButtonItem *nextBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Next", @"") style:UIBarButtonItemStylePlain target:self action:@selector(next)];
    self.navigationItem.rightBarButtonItem = nextBarButton;
}

- (void) setupProgressBar {
    self.stepProgressBar.rightLabel.text = NSLocalizedString(@"Mandatory", @"");
    [self setStepNumber:1 title:NSLocalizedString(@"General Information", @"")];
}

- (void) addFooterView {
    UIView *footerView = [[UINib nibWithNibName:@"SignUpGeneralInfoFooterView" bundle:nil] instantiateWithOwner:self options:nil][0];
    self.tableView.tableFooterView = footerView;
}


#pragma mark - IBActions

- (IBAction) agree {
    self.agreeButton.selected = !self.agreeButton.isSelected;
}


#pragma mark - Private Methods

- (void) next {
    APCSignUpMedicalInfoViewController *medicalInfoViewController = [APCSignUpMedicalInfoViewController new];
    medicalInfoViewController.profile = self.profile;
    
    [self.navigationController pushViewController:medicalInfoViewController animated:YES];
}

@end
