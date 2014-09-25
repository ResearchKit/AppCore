//
//  APCSignupViewController.m
//  APCAppleCore
//
//  Created by Karthik Keyan on 9/3/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCProfile.h"
#import "UIView+Helper.h"
#import "APCStepProgressBar.h"
#import "APCUserInfoConstants.h"
#import "APCSignupViewController.h"

static NSInteger kNumberOfSteps = 5;

@interface APCSignupViewController ()

@end

@implementation APCSignupViewController

@synthesize stepProgressBar;

@synthesize profile = _profile;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addProgressBar];
}
- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) addProgressBar {
    // Need to put step progress bar just below navigation bar,
    // So the UINavigationBar's end position will be the begining of step progress bar
    CGFloat stepProgressByYPosition = self.navigationController.navigationBar.bottom;
    
    self.stepProgressBar = [[APCStepProgressBar alloc] initWithFrame:CGRectMake(0, stepProgressByYPosition, self.view.width, kAPCSignUpProgressBarHeight)
                                                               style:APCStepProgressBarStyleOnlyProgressView];
    self.stepProgressBar.numberOfSteps = kNumberOfSteps;
    [self.view addSubview:self.stepProgressBar];
}


#pragma mark - Getter Methods

- (APCProfile *) profile {
    if (!_profile) {
        _profile = [APCProfile new];
    }
    
    return _profile;
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
