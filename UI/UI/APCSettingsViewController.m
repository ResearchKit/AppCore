//
//  SettingsViewController.m
//  UI
//
//  Created by Karthik Keyan on 9/2/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCProfile.h"
#import "APCSettingsViewController.h"

@interface APCSettingsViewController ()

@property (weak, nonatomic) IBOutlet UIView *footerConsentView;
@property (weak, nonatomic) IBOutlet UILabel *footerDiseaseLabel;
@property (weak, nonatomic) IBOutlet UILabel *studyPeriodLabel;
@property (weak, nonatomic) IBOutlet UIButton *reviewConsentButton;
@property (weak, nonatomic) IBOutlet UIButton *leaveStudyButton;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;

@end

@implementation APCSettingsViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.fields = @[@(APCUserInfoFieldUserName), @(APCUserInfoFieldEmail), @(APCUserInfoFieldDateOfBirth), @(APCUserInfoFieldMedicalCondition), @(APCUserInfoFieldMedication), @(APCUserInfoFieldBloodType), @(APCUserInfoFieldWeight), @(APCUserInfoFieldGender)];
        
        self.profile = [APCProfile new];
        self.profile.firstName = @"Karthik Keyan";
        self.profile.lastName = @"Balan";
        self.profile.userName = @"karthikkeyan";
        self.profile.email = @"karthikkeyan.balan@gmail.com";
        self.profile.dateOfBirth = [NSDate date];
        self.profile.medicalCondition = self.medicalConditions[0];
        self.profile.medication = self.medications[0];
        self.profile.bloodType = self.bloodTypes[0];
        self.profile.weight = @(160);
    }
    
    return self;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    
    [self addFooterView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UI Methods

- (void) addFooterView {
    UIView *footerView = [[UINib nibWithNibName:@"SettingsTableFooterView" bundle:nil] instantiateWithOwner:self options:nil][0];
    self.tableView.tableFooterView = footerView;
    
    UIColor *color = [UIColor colorWithWhite:0.8 alpha:0.5];
    
    self.footerConsentView.layer.borderWidth = 1.0;
    self.footerConsentView.layer.borderColor = color.CGColor;
    
    self.reviewConsentButton.layer.borderWidth = 1.0;
    self.reviewConsentButton.layer.borderColor = color.CGColor;
    
    self.leaveStudyButton.layer.borderWidth = 1.0;
    self.leaveStudyButton.layer.borderColor = color.CGColor;
}


#pragma mark - IBActions

- (IBAction) profileImageViewTapped:(UITapGestureRecognizer *)sender {
    
}


- (IBAction) reviewConsent {
    
}


- (IBAction) leaveStudy {
    
}

- (IBAction) logout {
    
}


@end
