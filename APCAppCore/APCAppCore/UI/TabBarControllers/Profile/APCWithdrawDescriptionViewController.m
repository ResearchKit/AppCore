//
//  APCWithdrawDescriptionViewController.m
//  AppCore
//
//  Copyright (c) 2014 Apple Inc. All rights reserved.
//

#import "APCWithdrawDescriptionViewController.h"
#import "UIColor+APCAppearance.h"
#import "UIFont+APCAppearance.h"
#import "UIImage+APCHelper.h"

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
    
    [self.doneButton setBackgroundImage:[UIImage imageWithColor:[UIColor appPrimaryColor]] forState:UIControlStateNormal];
    [self.doneButton.titleLabel setFont:[UIFont appMediumFontWithSize:19.0f]];
    
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

- (IBAction)done:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(withdrawViewController:didFinishWithDescription:)]) {
        [self.delegate withdrawViewController:self didFinishWithDescription:self.textView.text];
    }
}

- (IBAction)cancel:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(withdrawViewControllerDidCancel:)]) {
        [self.delegate withdrawViewControllerDidCancel:self];
    }
}

@end
