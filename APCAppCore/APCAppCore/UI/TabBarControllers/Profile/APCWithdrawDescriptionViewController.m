// 
//  APCWithdrawDescriptionViewController.m 
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
 
#import "APCWithdrawDescriptionViewController.h"
#import "UIColor+APCAppearance.h"
#import "UIFont+APCAppearance.h"
#import "UIImage+APCHelper.h"
#import "APCAppCore.h"

@interface APCWithdrawDescriptionViewController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewBottomLayoutConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *doneButtonBottomLayoutConstraint;

@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@end

@implementation APCWithdrawDescriptionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    self.textView.text = self.descriptionText;
    self.doneButton.enabled = (self.textView.text.length > 0);
    
    [self setupAppearance];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.textView becomeFirstResponder];
  APCLogViewControllerAppeared();
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

- (void)setupAppearance
{
    [self.textView setFont:[UIFont appRegularFontWithSize:15.0f]];
    [self.textView setTextColor:[UIColor appSecondaryColor1]];
    
    [self.messageLabel setFont:[UIFont appLightFontWithSize:14.0f]];
    [self.messageLabel setTextColor:[UIColor appSecondaryColor2]];
}

#pragma mark - UITextViewDelegate methods

- (void)textViewDidChange:(UITextView *)textView
{
    self.doneButton.enabled = (textView.text.length > 0);
}

#pragma mark - Keyboard Notifications

- (void)keyboardWillShow:(NSNotification *)notifcation
{
    CGFloat keyboardHeight = [notifcation.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    
    double animationDuration = [notifcation.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:animationDuration animations:^{
        self.doneButtonBottomLayoutConstraint.constant = keyboardHeight;
        self.textViewBottomLayoutConstraint.constant = keyboardHeight + CGRectGetHeight(self.doneButton.frame);
    }];
    
}

#pragma mark - IBActions

- (IBAction)done:(id) __unused sender
{
    if ([self.delegate respondsToSelector:@selector(withdrawViewController:didFinishWithDescription:)]) {
        [self.delegate withdrawViewController:self didFinishWithDescription:self.textView.text];
    }
}

- (IBAction)cancel:(id) __unused sender
{
    if ([self.delegate respondsToSelector:@selector(withdrawViewControllerDidCancel:)]) {
        [self.delegate withdrawViewControllerDidCancel:self];
    }
}

@end
