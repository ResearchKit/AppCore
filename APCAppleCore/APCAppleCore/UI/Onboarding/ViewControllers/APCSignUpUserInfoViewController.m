//
//  APCSignUpUserInfoViewController.m
//  APCAppleCore
//
//  Created by Karthik Keyan on 9/3/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCUser.h"
#import "APCUser+HealthKit.h"
#import "UIView+Helper.h"
#import "APCStepProgressBar.h"
#import "APCUserInfoConstants.h"
#import "APCSignUpUserInfoViewController.h"

@interface APCSignUpUserInfoViewController ()

@end

@implementation APCSignUpUserInfoViewController

@synthesize stepProgressBar;

@synthesize user = _user;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Sign Up", nil);
    [self addProgressBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillLayoutSubviews
{
    //Frame.origin.y is negative to account for the tableView content Inset.
    self.stepProgressBar.frame = CGRectMake(0, -kAPCSignUpProgressBarHeight, self.view.width, kAPCSignUpProgressBarHeight);
}

- (void) addProgressBar {
    // Need to put step progress bar just below navigation bar,
    // So the UINavigationBar's end position will be the begining of step progress bar
//    CGFloat stepProgressByYPosition = self.topLayoutGuide.length;
    
    self.stepProgressBar = [[APCStepProgressBar alloc] initWithFrame:CGRectMake(0, -kAPCSignUpProgressBarHeight, self.view.width, kAPCSignUpProgressBarHeight)
                                                               style:APCStepProgressBarStyleDefault];
    self.stepProgressBar.numberOfSteps = 4;
    [self.view addSubview:self.stepProgressBar];
    
    
    // Instead of reducing table view height, we can just adjust tableview scroll insets
    UIEdgeInsets inset = self.tableView.contentInset;
    inset.top += self.stepProgressBar.height;
    
    self.tableView.contentInset = inset;
}


#pragma mark - Getter Methods

- (APCUser *) user {
    if (!_user) {
        _user = [APCUser new];
    }
    
    return _user;
}


#pragma mark - Public Methods

- (void) setStepNumber:(NSUInteger)stepNumber title:(NSString *)title {
    NSString *step = [NSString stringWithFormat:NSLocalizedString(@"Step %i", @""), stepNumber];
    
    NSString *string = [NSString stringWithFormat:@"%@: %@", step, title];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    [attributedString setAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14]} range:NSMakeRange(0, string.length)];
    [attributedString setAttributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:14]} range:NSMakeRange(0, step.length)];
    
    self.stepProgressBar.leftLabel.attributedText = attributedString;
}

@end
