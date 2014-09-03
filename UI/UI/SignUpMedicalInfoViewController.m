//
//  SignUpMedicalInfoViewController.m
//  UI
//
//  Created by Karthik Keyan on 9/2/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "SignUpMedicalInfoViewController.h"

@interface SignUpMedicalInfoViewController ()

@end

@implementation SignUpMedicalInfoViewController

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
    // Do any additional setup after loading the view.
    self.tableView.tableHeaderView = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
