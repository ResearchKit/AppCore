// 
//  APCSimpleTaskSummaryViewController.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "APCSimpleTaskSummaryViewController.h"
#import "APCAppCore.h"

@interface APCSimpleTaskSummaryViewController ()

@property (weak, nonatomic) IBOutlet UILabel *completingActivitiesMessage;
@property (weak, nonatomic) IBOutlet UILabel *thankYouBanner;
@property (weak, nonatomic) IBOutlet UILabel *youCanCompareMessage;
@property (weak, nonatomic) IBOutlet APCConfirmationView *confirmation;

@end

@implementation APCSimpleTaskSummaryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIColor *viewBackgroundColor = [UIColor appSecondaryColor4];
    
    [self.view setBackgroundColor:viewBackgroundColor];
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.hidesBackButton = YES;
    
    APCAppDelegate *appDelegate = (APCAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSUInteger allScheduledTasks = appDelegate.dataSubstrate.countOfAllScheduledTasksForToday;
    NSUInteger completedScheduledTasks = appDelegate.dataSubstrate.countOfCompletedScheduledTasksForToday;
    
    NSNumber *remainingTasks = (completedScheduledTasks < allScheduledTasks) ? @(allScheduledTasks - completedScheduledTasks) : @(0);
    
    UITabBarItem *activitiesTab = appDelegate.tabster.tabBar.selectedItem;
    
    if ([remainingTasks integerValue] != 0) {
        activitiesTab.badgeValue = [remainingTasks stringValue];
    } else {
        activitiesTab.badgeValue = nil;
    }
    
    self.confirmation.completed = YES;
    
    [self setUpAppearance];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
  APCLogViewControllerAppeared();
}

- (void) setUpAppearance
{
    self.completingActivitiesMessage.font = [UIFont appLightFontWithSize:17];
    self.completingActivitiesMessage.textColor = [UIColor appSecondaryColor3];
    self.youCanCompareMessage.textColor = [UIColor appSecondaryColor2];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self
                                                                                           action:@selector(doneButtonTapped:)];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] init];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Actions

- (void)doneButtonTapped:(UIBarButtonItem *) __unused sender
{
    if (self.delegate != nil) {
        if ([self.delegate respondsToSelector:@selector(stepViewController:didFinishWithNavigationDirection:)] == YES) {
            [self.delegate stepViewController:self didFinishWithNavigationDirection: ORKStepViewControllerNavigationDirectionForward];
        }
    }
}



@end
