//
//  APHFitnessTestSummaryViewController.m
//  CardioHealth
//
//  Created by Justin Warmkessel on 10/21/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCSimpleTaskSummaryViewController.h"
#import "APCAppleCore.h"

static NSString *const kCheckImageName = @"Completion-Check";

@interface APCSimpleTaskSummaryViewController ()

@property (weak, nonatomic) IBOutlet UILabel *label1;
@property (weak, nonatomic) IBOutlet UILabel *label2;
@property (weak, nonatomic) IBOutlet UILabel *label3;
@property (weak, nonatomic) IBOutlet UILabel *label4;
@property (weak, nonatomic) IBOutlet UILabel *label5;

@property (weak, nonatomic) IBOutlet UIView *circularProgressBar;

@property (weak, nonatomic) IBOutlet UIImageView *checkImage;


@property (nonatomic, strong) APCCircularProgressView *circularProgress;

@end

@implementation APCSimpleTaskSummaryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIColor *viewBackgroundColor = [UIColor appSecondaryColor4];
    self.label1.textColor = [UIColor appSecondaryColor3];
    [self.view setBackgroundColor:viewBackgroundColor];
    self.navigationController.navigationBar.topItem.title = NSLocalizedString(@"Complete", @"Complete");
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.hidesBackButton = YES;
    
    self.circularProgress = [[APCCircularProgressView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.circularProgressBar.frame), CGRectGetHeight(self.circularProgressBar.frame))];
    self.circularProgress.hidesProgressValue = YES;
    NSUInteger allScheduledTasks = ((APCAppDelegate *)[UIApplication sharedApplication].delegate).dataSubstrate.countOfAllScheduledTasksForToday;
    NSUInteger completedScheduledTasks = ((APCAppDelegate *)[UIApplication sharedApplication].delegate).dataSubstrate.countOfCompletedScheduledTasksForToday;
    completedScheduledTasks = MIN(allScheduledTasks, completedScheduledTasks+1);
    CGFloat percent = (CGFloat) completedScheduledTasks / (CGFloat) allScheduledTasks;
    [self.circularProgress setProgress:percent];
    self.circularProgress.tintColor = [UIColor appTertiaryColor1];
    [self.circularProgressBar addSubview:self.circularProgress];
    
    self.label3.text = [NSString stringWithFormat:@"%lu/%lu", (unsigned long)completedScheduledTasks, (unsigned long)allScheduledTasks];
    
    self.checkImage.image = [UIImage imageNamed:kCheckImageName];
    
    [self setUpAppearance];
}

- (void) setUpAppearance
{
    self.label1.font = [UIFont appLightFontWithSize:17];
    self.label1.textColor = [UIColor appSecondaryColor3];
    
    self.label3.textColor = [UIColor appSecondaryColor3];
    
    self.label5.textColor = [UIColor appSecondaryColor2];
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
