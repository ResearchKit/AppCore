// 
//  APCSignUpInfoViewController.m 
//  APCAppCore 
// 
// Copyright (c) 2015, Apple Inc. All rights reserved. 
// 
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
// 
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
// 
// 2.  Redistributions in binary form must reproduce the above copyright notice, 
// this list of conditions and the following disclaimer in the documentation and/or 
// other materials provided with the distribution. 
// 
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors 
// may be used to endorse or promote products derived from this software without 
// specific prior written permission. No license is granted to the trademarks of 
// the copyright holders even if such marks are included in this software. 
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE 
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
// 
 
#import "APCSignUpInfoViewController.h"
#import "APCOnboardingManager.h"
#import "APCUserInfoConstants.h"
#import "APCDataSubstrate.h"
#import "APCUser.h"
#import "APCLog.h"
#import "APCStepProgressBar.h"

#import "NSString+Helper.h"
#import "UIColor+APCAppearance.h"
#import "UIFont+APCAppearance.h"


static CGFloat const kHeaderHeight = 127.0f;

@interface APCSignUpInfoViewController ()

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *email;

@end

@implementation APCSignUpInfoViewController

@synthesize stepProgressBar;

- (void)dealloc {
    _nameTextField.delegate = nil;
    _emailTextField.delegate = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupAppearance];
    
    self.nameTextField.delegate = self;
    self.emailTextField.delegate = self;
    
    self.editing = YES;
    self.signUp = YES;
    
    [self.profileImageButton.imageView setContentMode:UIViewContentModeScaleAspectFill];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UIEdgeInsets inset = self.tableView.contentInset;
    self.tableView.contentInset = inset;
    
    if (self.headerView && (CGRectGetHeight(self.headerView.frame) != kHeaderHeight)) {
        CGRect headerRect = self.headerView.frame;
        headerRect.size.height = kHeaderHeight;
        self.headerView.frame = headerRect; 
        
        self.tableView.tableHeaderView = self.tableView.tableHeaderView;
    }
    APCLogViewControllerAppeared();
}

#pragma mark -

- (void)setStepNumber:(NSUInteger)stepNumber title:(NSString *)title
{
    NSString *step = [NSString stringWithFormat:NSLocalizedString(@"Step %i", @""), stepNumber];
    
    NSString *string = [NSString stringWithFormat:@"%@: %@", step, title];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    [attributedString setAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14]} range:NSMakeRange(0, string.length)];
    [attributedString setAttributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:14]} range:NSMakeRange(0, step.length)];
    
    self.stepProgressBar.leftLabel.attributedText = attributedString;
}

- (APCOnboarding *)onboarding {
    return [(id<APCOnboardingManagerProvider>)[UIApplication sharedApplication].delegate onboardingManager].onboarding;
}

- (APCUser *)user {
    return [(id<APCOnboardingManagerProvider>)[UIApplication sharedApplication].delegate onboardingManager].user;
}

#pragma mark - Appearance

- (void)setupAppearance
{
    [self.nameTextField setTextColor:[UIColor appSecondaryColor1]];
    [self.nameTextField setFont:[UIFont appRegularFontWithSize:16.0f]];
    
    [self.emailTextField setTextColor:[UIColor appSecondaryColor1]];
    [self.emailTextField setFont:[UIFont appRegularFontWithSize:16.0f]];
    
    [self.profileImageButton.imageView.layer setCornerRadius:CGRectGetHeight(self.profileImageButton.bounds)/2];
    
    [self.footerLabel setTextColor:[UIColor appSecondaryColor1]];
    [self.footerLabel setFont:[UIFont appRegularFontWithSize:16.0f]];
    
}

#pragma mark - Custom Methods

- (void)setupPickerCellAppeareance:(APCPickerTableViewCell *) __unused cell
{

}

- (void)setupTextFieldCellAppearance:(APCTextFieldTableViewCell *)cell
{
    [cell.textLabel setFont:[UIFont appRegularFontWithSize:17.0f]];
    [cell.textLabel setTextColor:[UIColor appSecondaryColor1]];
    
    [cell.textField setFont:[UIFont appRegularFontWithSize:17.0f]];
    [cell.textField setTextColor:[UIColor appSecondaryColor1]];
}

- (void)setupSegmentedCellAppearance:(APCSegmentedTableViewCell *) __unused cell
{
    
}

- (void)setupDefaultCellAppearance:(APCDefaultTableViewCell *)cell
{
    [cell.textLabel setFont:[UIFont appRegularFontWithSize:17.0f]];
    [cell.textLabel setTextColor:[UIColor appSecondaryColor1]];
    
    [cell.detailTextLabel setFont:[UIFont appRegularFontWithSize:17.0f]];
    [cell.detailTextLabel setTextColor:[UIColor appSecondaryColor1]];
}

#pragma mark - UITextFieldDelegate methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (textField == self.nameTextField) {
        self.name = text;
    } else if (textField == self.emailTextField){
        self.email = text;
    }
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == self.nameTextField) {
        self.name = textField.text;
    } else if (textField == self.emailTextField){
        self.email = textField.text;
    }
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    
    if ((textField == self.nameTextField) && self.emailTextField) {
        [self.emailTextField becomeFirstResponder];
    } else {
        [self nextResponderForIndexPath:nil];
    }
    
    return YES;
}


#pragma mark - Private Methods

- (BOOL) isContentValid:(NSString **)errorMessage {
    
    BOOL isContentValid = YES;
    
    if (self.tableView.tableHeaderView) {
        if (![self.emailTextField.text isValidForRegex:kAPCGeneralInfoItemEmailRegEx]){
            isContentValid = NO;
            
            if (errorMessage) {
                *errorMessage = NSLocalizedString(@"Please enter a valid email address.", @"");
            }
        }
    }
    
    return isContentValid;
}

- (void)next{
    
}


@end
