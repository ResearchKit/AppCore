//
//  SignUpGeneralInfoViewController.m
//  OnBoarding
//
//  Created by Karthik Keyan on 9/2/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "Profile.h"
#import "SignUpGeneralInfoViewController.h"
#import "SignUpMedicalInfoViewController.h"

@interface SignUpGeneralInfoViewController ()

@property (nonatomic, strong) UITableView *userTableView;

@property (weak, nonatomic) IBOutlet UIButton *agreeButton;

@end

@implementation SignUpGeneralInfoViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.fields = @[@(UserInfoFieldEmail), @(UserInfoFieldPassword), @(UserInfoFieldDateOfBirth), @(UserInfoFieldGender)];
        self.profile = [Profile new];
    }
    return self;
}

- (void) loadView {
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *nextBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Next", @"") style:UIBarButtonItemStylePlain target:self action:@selector(next)];
    self.navigationItem.rightBarButtonItem = nextBarButton;
    
    [self addFooterView];
}


#pragma mark - UI Methods

- (void) addFooterView {
    UIView *footerView = [[UINib nibWithNibName:@"SignUpGeneralInfoFooterView" bundle:nil] instantiateWithOwner:self options:nil][0];
    self.tableView.tableFooterView = footerView;
}


#pragma mark - UITableViewDelegate

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = [super tableView:tableView heightForRowAtIndexPath:indexPath];
    
    return height + 10;
}


#pragma mark - IBActions

- (IBAction) agree {
    self.agreeButton.selected = !self.agreeButton.isSelected;
}


#pragma mark - Private Methods

- (void) next {
    SignUpMedicalInfoViewController *medicalInfoViewController = [SignUpMedicalInfoViewController new];
    medicalInfoViewController.profile = self.profile;
    
    [self.navigationController pushViewController:medicalInfoViewController animated:YES];
}

@end
