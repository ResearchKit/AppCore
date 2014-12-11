// 
//  APCSignUpInfoViewController.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "APCSignUpInfoViewController.h"
#import "APCAppDelegate.h"
#import "APCUserInfoConstants.h"
#import "APCStepProgressBar.h"
#import "NSString+Helper.h"
#import "UIColor+APCAppearance.h"
#import "UIFont+APCAppearance.h"
#import "APCAppDelegate.h"
#import "APCAppCore.h"

static CGFloat const kHeaderHeight = 127.0f;

@interface APCSignUpInfoViewController ()

@property (nonatomic, getter=isPickerShowing) BOOL pickerShowing;

@property (nonatomic, strong) NSIndexPath *pickerIndexPath;

@end

@implementation APCSignUpInfoViewController

@synthesize stepProgressBar;
@synthesize user = _user;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupStepProgressBar];
    [self setupAppearance];
    
    self.firstNameTextField.delegate = self;
    self.lastNameTextField.delegate = self;
    
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

- (void)setupStepProgressBar
{
    self.stepProgressBar = [[APCStepProgressBar alloc] initWithFrame:CGRectMake(0, -kAPCSignUpProgressBarHeight, CGRectGetWidth(self.view.frame), kAPCSignUpProgressBarHeight)
                                                               style:APCStepProgressBarStyleOnlyProgressView];
    self.stepProgressBar.numberOfSteps = [self onboarding].onboardingTask.numberOfSteps;
    [self.view addSubview:self.stepProgressBar];
    
    
    // Instead of reducing table view height, we can just adjust tableview scroll insets
    UIEdgeInsets inset = self.tableView.contentInset;
    inset.top += CGRectGetHeight(self.stepProgressBar.frame);
    
    self.tableView.contentInset = inset;
}

- (void)setStepNumber:(NSUInteger)stepNumber title:(NSString *)title
{
    NSString *step = [NSString stringWithFormat:NSLocalizedString(@"Step %i", @""), stepNumber];
    
    NSString *string = [NSString stringWithFormat:@"%@: %@", step, title];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    [attributedString setAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14]} range:NSMakeRange(0, string.length)];
    [attributedString setAttributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:14]} range:NSMakeRange(0, step.length)];
    
    self.stepProgressBar.leftLabel.attributedText = attributedString;
}

- (APCUser *) user {
    if (!_user) {
        _user = ((APCAppDelegate*) [UIApplication sharedApplication].delegate).dataSubstrate.currentUser;
    }
    
    return _user;
}

- (APCOnboarding *)onboarding
{
    return ((APCAppDelegate *)[UIApplication sharedApplication].delegate).onboarding;
}

#pragma mark - Appearance

- (void)setupAppearance
{
    [self.firstNameTextField setTextColor:[UIColor appSecondaryColor1]];
    [self.firstNameTextField setFont:[UIFont appRegularFontWithSize:16.0f]];
    
    [self.lastNameTextField setTextColor:[UIColor appSecondaryColor1]];
    [self.lastNameTextField setFont:[UIFont appRegularFontWithSize:16.0f]];
    
    [self.profileImageButton.imageView.layer setCornerRadius:CGRectGetHeight(self.profileImageButton.bounds)/2];
    
    [self.footerLabel setTextColor:[UIColor appSecondaryColor3]];
    [self.footerLabel setFont:[UIFont appRegularFontWithSize:14.0f]];
    
}

#pragma mark - Custom Methods

- (void)setupPickerCellAppeareance:(APCPickerTableViewCell *)cell
{

}

- (void)setupTextFieldCellAppearance:(APCTextFieldTableViewCell *)cell
{
    [cell.textLabel setFont:[UIFont appRegularFontWithSize:14.0f]];
    [cell.textLabel setTextColor:[UIColor appSecondaryColor1]];
    
    [cell.textField setFont:[UIFont appRegularFontWithSize:17.0f]];
    [cell.textField setTextColor:[UIColor appSecondaryColor1]];
}

- (void)setupSegmentedCellAppearance:(APCSegmentedTableViewCell *)cell
{
    
}

- (void)setupDefaultCellAppearance:(APCDefaultTableViewCell *)cell
{
    [cell.textLabel setFont:[UIFont appRegularFontWithSize:14.0f]];
    [cell.textLabel setTextColor:[UIColor appSecondaryColor1]];
    
    [cell.detailTextLabel setFont:[UIFont appRegularFontWithSize:17.0f]];
    [cell.detailTextLabel setTextColor:[UIColor appSecondaryColor1]];
}

#pragma mark - UITextFieldDelegate methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (textField == self.firstNameTextField) {
        self.user.firstName = text;
    } else if (textField == self.lastNameTextField){
        self.user.lastName = text;
    }
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == self.firstNameTextField) {
        self.user.firstName = textField.text;
    } else if (textField == self.lastNameTextField){
        self.user.lastName = textField.text;
    }
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    
    if ((textField == self.firstNameTextField) && self.lastNameTextField) {
        [self.lastNameTextField becomeFirstResponder];
    } else {
        [self nextResponderForIndexPath:nil];
    }
    
    return YES;
}


#pragma mark - Private Methods

- (BOOL) isContentValid:(NSString **)errorMessage {
    
    BOOL isContentValid = YES;
    
    if (self.tableView.tableHeaderView) {
        if (![self.firstNameTextField.text isValidForRegex:kAPCUserInfoFieldNameRegEx]) {
            isContentValid = NO;
            
            if (errorMessage) {
                *errorMessage = NSLocalizedString(@"Please enter a valid first name.", @"");
            }
        } else if (![self.lastNameTextField.text isValidForRegex:kAPCUserInfoFieldNameRegEx]){
            isContentValid = NO;
            
            if (errorMessage) {
                *errorMessage = NSLocalizedString(@"Please enter a valid last name.", @"");
            }
        }
    }
    
    return isContentValid;
}

- (void)next{
    
}


@end
