//
//  APCSignupViewController.m
//  UI
//
//  Created by Karthik Keyan on 9/3/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCStepProgressBar.h"
#import "APCSignupViewController.h"

@interface APCSignupViewController ()

@end

@implementation APCSignupViewController

@synthesize stepProgressBar;

@synthesize profile;

- (void) loadView {
    if (self.nibName) {
        [super loadView];
    }
    else {
        self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        self.view.backgroundColor = [UIColor whiteColor];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addProgressBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) addProgressBar {
    // Need to put step progress bar just below navigation bar,
    // So the UINavigationBar's end position will be the begining of step progress bar
    CGFloat stepProgressByYPosition = CGRectGetMaxY(self.navigationController.navigationBar.frame);
    
    self.stepProgressBar = [[APCStepProgressBar alloc] initWithFrame:CGRectMake(0, stepProgressByYPosition, self.view.bounds.size.width, kAPCSignUpProgressBarHeight)
                                                               style:APCStepProgressBarStyleOnlyProgressView];
    self.stepProgressBar.numberOfSteps = 4;
    [self.view addSubview:self.stepProgressBar];
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
