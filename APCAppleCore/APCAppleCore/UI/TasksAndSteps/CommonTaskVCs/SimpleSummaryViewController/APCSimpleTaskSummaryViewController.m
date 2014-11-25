//
//  APHFitnessTestSummaryViewController.m
//  CardioHealth
//
//  Created by Justin Warmkessel on 10/21/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCSimpleTaskSummaryViewController.h"
#import "APCAppleCore.h"

@interface APCSimpleTaskSummaryViewController ()

@property (weak, nonatomic) IBOutlet UILabel *completingActivitiesMessage;
@property (weak, nonatomic) IBOutlet UILabel *todaysActivitiesMessage;
@property (weak, nonatomic) IBOutlet UILabel *numberOfActivitiesCompleted;
@property (weak, nonatomic) IBOutlet UILabel *thankYouBanner;
@property (weak, nonatomic) IBOutlet UILabel *youCanCompareMessage;

@property (weak, nonatomic) IBOutlet UIView  *circularProgressBar;

@property (weak, nonatomic) IBOutlet APCConfirmationView *confirmation;

@property (nonatomic, strong) APCCircularProgressView *circularProgress;

@end

@implementation APCSimpleTaskSummaryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIColor *viewBackgroundColor = [UIColor appSecondaryColor4];
    self.completingActivitiesMessage.textColor = [UIColor appSecondaryColor3];
    [self.view setBackgroundColor:viewBackgroundColor];
    self.navigationController.navigationBar.topItem.title = NSLocalizedString(@"Activity Complete", @"Activity Complete");
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.hidesBackButton = YES;
    
    self.circularProgress = [[APCCircularProgressView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.circularProgressBar.frame), CGRectGetHeight(self.circularProgressBar.frame))];
    self.circularProgress.hidesProgressValue = YES;
    NSUInteger allScheduledTasks = ((APCAppDelegate *)[UIApplication sharedApplication].delegate).dataSubstrate.allScheduledTasksForToday;
    NSUInteger completedScheduledTasks = ((APCAppDelegate *)[UIApplication sharedApplication].delegate).dataSubstrate.completedScheduledTasksForToday;
    completedScheduledTasks = MIN(allScheduledTasks, completedScheduledTasks+1);
    CGFloat percent = (CGFloat) completedScheduledTasks / (CGFloat) allScheduledTasks;
    [self.circularProgress setProgress:percent];
    self.circularProgress.tintColor = [UIColor appTertiaryColor1];
    [self.circularProgressBar addSubview:self.circularProgress];
    
    self.numberOfActivitiesCompleted.text = [NSString stringWithFormat:@"%lu/%lu", (unsigned long)completedScheduledTasks, (unsigned long)allScheduledTasks];
    
    self.confirmation.completed = YES;
    
    [self setUpAppearance];
}

- (void) setUpAppearance
{
    self.completingActivitiesMessage.font = [UIFont appLightFontWithSize:17];
    self.completingActivitiesMessage.textColor = [UIColor appSecondaryColor3];
    
    self.numberOfActivitiesCompleted.textColor = [UIColor appSecondaryColor3];
    
    self.youCanCompareMessage.textColor = [UIColor appSecondaryColor2];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    CGRect rect = CGRectMake(0, 0, CGRectGetWidth(self.circularProgressBar.frame), CGRectGetHeight(self.circularProgressBar.frame));
    [self.circularProgress setFrame:rect];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self
                                                                                           action:@selector(doneButtonTapped:)];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

//    [self.progressBar setCompletedSteps:6 animation:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (void)doneButtonTapped:(UIBarButtonItem *)sender
{
    if (self.delegate != nil) {
        if ([self.delegate respondsToSelector:@selector(stepViewControllerDidFinish:navigationDirection:)] == YES) {
            [self.delegate stepViewControllerDidFinish:self navigationDirection:RKSTStepViewControllerNavigationDirectionForward];
        }
    }
}



@end
