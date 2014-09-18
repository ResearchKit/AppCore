//
//  APCForgotPasswordViewController.m
//  APCAppleCore
//
//  Created by Karthik Keyan on 9/4/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "NSString+Helper.h"
#import "UIAlertView+Helper.h"
#import "APCUserInfoConstants.h"
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
    nextBarButton.enabled = NO;
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
    
    if ([self.emaiTextField.text isValidForRegex:(NSString *)kAPCGeneralInfoItemEmailRegEx]) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
        [UIAlertView showSimpleAlertWithTitle:NSLocalizedString(@"General Information", @"") message:NSLocalizedString(@"Please give a valid email address", @"")];
    }
}

@end
