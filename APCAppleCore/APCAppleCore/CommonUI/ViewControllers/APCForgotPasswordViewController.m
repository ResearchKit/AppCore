//
//  APCSignInViewController.m
//  UI
//
//  Created by Karthik Keyan on 9/4/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCForgotPasswordViewController.h"

@interface APCForgotPasswordViewController ()

@end

@implementation APCForgotPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addNavigationItems];
}

- (void) addNavigationItems {
    self.title = NSLocalizedString(@"Reset Password", @"");
    
    UIBarButtonItem *nextBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Send", @"") style:UIBarButtonItemStylePlain target:self action:@selector(sendPassword)];
    self.navigationItem.rightBarButtonItem = nextBarButton;
}


#pragma mark - UITextFieldDelegate
- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [self sendPassword];
    
    return YES;
}


#pragma mark - Public Methods

- (void) sendPassword {
    [self.emaiTextField resignFirstResponder];
}

@end
