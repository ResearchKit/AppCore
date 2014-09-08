//
//  SignUpGeneralInfoViewController.m
//  OnBoarding
//
//  Created by Karthik Keyan on 9/2/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCProfile.h"
#import "APHUserInfoCell.h"
#import "APCStepProgressBar.h"
#import "UITableView+AppearanceCategory.h"
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
        self.fields = @[@(APCUserInfoFieldUserName), @(APCUserInfoFieldEmail), @(APCUserInfoFieldPassword), @(APCUserInfoFieldDateOfBirth), @(APCUserInfoFieldGender)];
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
    self.title = NSLocalizedString(@"General Information", @"");
    
    UIBarButtonItem *nextBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Next", @"") style:UIBarButtonItemStylePlain target:self action:@selector(next)];
    self.navigationItem.rightBarButtonItem = nextBarButton;
}

- (void) setupProgressBar {
    self.stepProgressBar.rightLabel.text = NSLocalizedString(@"Mandatory", @"");
}

- (void) addFooterView {
    UILabel *label = [UILabel new];
    label.frame = CGRectMake(0, 0, self.tableView.frame.size.width, 44);
    label.font = [UITableView footerFont];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UITableView footerTextColor];
    label.text = NSLocalizedString(@"All fields on this screen are required.", @"");
    self.tableView.tableFooterView = label;
}


- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    APCUserInfoCell *cell = (APCUserInfoCell *)[super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    APCUserInfoField field = [self.fields[indexPath.row] integerValue];
    
    if (field == APCUserInfoFieldDateOfBirth) {
        cell.valueTextField.textAlignment = NSTextAlignmentLeft;
    }
    
    return cell;
}

#pragma mark - IBActions

- (IBAction) agree {
    self.agreeButton.selected = !self.agreeButton.isSelected;
}


#pragma mark - Public Methods

- (Class) cellClass {
    return [APHUserInfoCell class];
}


#pragma mark - Private Methods

- (void) next {
    APCSignUpMedicalInfoViewController *medicalInfoViewController = [APCSignUpMedicalInfoViewController new];
    medicalInfoViewController.profile = self.profile;
    
    [self.navigationController pushViewController:medicalInfoViewController animated:YES];
}

@end
