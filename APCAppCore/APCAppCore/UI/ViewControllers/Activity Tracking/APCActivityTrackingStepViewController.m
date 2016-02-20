// 
//  Activity 
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
 
#import "APCActivityTrackingStepViewController.h"
#import "APCAppDelegate.h"
#import "APCFitnessAllocation.h"

static NSInteger const kYesterdaySegmentIndex    = 0;
static NSInteger const kTodaySegmentIndex        = 1;
static NSInteger const kWeekSegmentIndex         = 2;

static NSString   *kLearnMoreString = @"The circle shows estimates of the proportion of time you have been spending in different levels of activity, based on sensor data from your phone or wearable device. It also estimates your accumulated “active minutes,” which combines moderate and vigorous activities, and daily steps. This is intended to be informational, as accurate assessment of every type of activity from sensors is an ongoing area of research and development. Your data can help us refine these estimates and better understand the relationship between activity and heart health.";

static NSInteger const kSmallerFontSize = 16;
static NSInteger const kRegularFontSize = 17;

@interface APCActivityTrackingStepViewController () <APCPieGraphViewDatasource, UIGestureRecognizerDelegate >
- (IBAction)resetTaskStartDate:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *daysRemaining;
@property (weak, nonatomic) IBOutlet APCPieGraphView *chartView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentDays;

@property (nonatomic) NSInteger previouslySelectedSegment;

@property (nonatomic, strong) NSArray *allocationDataset;

@property (nonatomic, strong) NSDate *allocationStartDate;

@property (nonatomic) BOOL showTodaysDataAtViewLoad;
@property (nonatomic) NSInteger numberOfDaysOfFitnessWeek;
@property (weak, nonatomic) IBOutlet UIButton *infoIconButton;

@property (strong, nonatomic) UIImageView *customSurveylearnMoreView;

@end

@implementation APCActivityTrackingStepViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.daysRemaining.text = [self fitnessDaysRemaining];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(handleClose:)];


    self.view.layer.backgroundColor = [UIColor appSecondaryColor4].CGColor;
    
    self.segmentDays.tintColor = [UIColor clearColor];

    [self.segmentDays setTitleTextAttributes:@{
                                               NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue" size:kSmallerFontSize],
                                               NSForegroundColorAttributeName : [UIColor appPrimaryColor]
                                               
                                               }
                                    forState:UIControlStateNormal];
    [self.segmentDays setTitleTextAttributes:@{
                                               NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue" size:kSmallerFontSize],
                                               NSForegroundColorAttributeName : [UIColor whiteColor],
                                               
                                               }
                                    forState:UIControlStateSelected];
    [self.segmentDays setTitleTextAttributes:@{
                                               NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue" size:kSmallerFontSize],
                                               NSForegroundColorAttributeName : [UIColor lightGrayColor]
                                               }
                                    forState:UIControlStateDisabled];
    
    //[[UIView appearance] setTintColor:[UIColor whiteColor]];
    
    self.previouslySelectedSegment = kTodaySegmentIndex;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(datasetDidUpdate:)
                                                 name:APHSevenDayAllocationDataIsReadyNotification
                                               object:nil];
    
    self.showTodaysDataAtViewLoad = YES;
    
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.leftBarButtonItem = nil;
    
    self.chartView.datasource = self;
    self.chartView.legendPaddingHeight = 60.0;
    self.chartView.shouldAnimate = YES;
    self.chartView.shouldAnimateLegend = NO;
    self.chartView.titleLabel.text = NSLocalizedString(@"Active Minutes", @"Active Minutes");
    
    
    APCAppDelegate *appDelegate = (APCAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self.chartView.valueLabel.text = [NSString stringWithFormat:@"%d", (int) roundf(appDelegate.sevenDayFitnessAllocationData.activeSeconds/60)];
    self.chartView.valueLabel.alpha = 1;

    [self.infoIconButton setImage:[[UIImage imageNamed:@"info_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self.infoIconButton setImage:[[UIImage imageNamed:@"info_icon_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateHighlighted];
    self.infoIconButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.infoIconButton.imageView.tintColor = [UIColor appSecondaryColor1];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    APCAppDelegate *appDelegate = (APCAppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([appDelegate.sevenDayFitnessAllocationData todaysAllocation]) {
        if (self.showTodaysDataAtViewLoad) {
            [self handleDays:self.segmentDays];
            self.showTodaysDataAtViewLoad = NO;
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:APHSevenDayAllocationDataIsReadyNotification
                                                  object:nil];
    
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Actions

- (IBAction)handleDays:(UISegmentedControl *)sender
{
    APCAppDelegate *appDelegate = (APCAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    switch (sender.selectedSegmentIndex) {
        case 0:
            self.allocationDataset = [appDelegate.sevenDayFitnessAllocationData yesterdaysAllocation];
            break;
        case 1:
            self.allocationDataset = [appDelegate.sevenDayFitnessAllocationData todaysAllocation];
            break;
        default:
            self.allocationDataset = [appDelegate.sevenDayFitnessAllocationData weeksAllocation];
            break;
    }
    
    [self refreshAllocation:sender.selectedSegmentIndex];
}

- (void)handleClose:(UIBarButtonItem *) __unused sender
{
    if ([self.delegate respondsToSelector:@selector(stepViewController:didFinishWithNavigationDirection:)]) {
        [self.delegate stepViewController:self didFinishWithNavigationDirection:ORKStepViewControllerNavigationDirectionForward];
    }
}

- (NSDate *)dateForSpan:(NSInteger)daySpan
{
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:daySpan];
    
    NSDate *spanDate = [[NSCalendar currentCalendar] dateByAddingComponents:components
                                                                     toDate:[NSDate date]
                                                                    options:0];
    return spanDate;
}

- (NSString *)fitnessDaysRemaining
{
    NSDate *startDate = [self checkSevenDayFitnessStartDate];
    
    NSDate *today = [[NSCalendar currentCalendar] dateBySettingHour:0
                                                             minute:0
                                                             second:0
                                                             ofDate:[NSDate date]
                                                            options:0];
    
    // Disable Yesterday and Week segments when start date is today
    BOOL startDateIsToday = [startDate isEqualToDate:today];
    [self.segmentDays setEnabled:!startDateIsToday forSegmentAtIndex:0];
    [self.segmentDays setEnabled:!startDateIsToday forSegmentAtIndex:2];
    
    // Compute the remaing days of the 7 day fitness allocation.
    NSDateComponents *numberOfDaysFromStartDate = [[NSCalendar currentCalendar] components:NSCalendarUnitDay
                                                                                  fromDate:startDate
                                                                                    toDate:today
                                                                                   options:NSCalendarWrapComponents];
    self.numberOfDaysOfFitnessWeek = numberOfDaysFromStartDate.day;
    
    NSUInteger daysRemain = 0;
    
    if (self.numberOfDaysOfFitnessWeek < 7) {
        daysRemain = 7 - self.numberOfDaysOfFitnessWeek;
    }

    NSString *days = (daysRemain == 1) ? NSLocalizedString(@"Day", @"Day") : NSLocalizedString(@"Days", @"Days");
    
    NSString *remaining = [NSString stringWithFormat:NSLocalizedString(@"%lu %@ Remaining",
                                                                       @"{count} {day/s} Remaining"), daysRemain, days];
    
    if (daysRemain <= 0)
    {
        remaining = NSLocalizedString(@"Here is your activity and sleep assessment for the last 7 days", @"");
    }
    
    return remaining;
}

- (NSDate *)checkSevenDayFitnessStartDate
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSDate *fitnessStartDate = [defaults objectForKey:kSevenDayFitnessStartDateKey];
    
    if (!fitnessStartDate) {
        
        NSDate *startDate = [[NSCalendar currentCalendar] dateBySettingHour:0
                                                                     minute:0
                                                                     second:0
                                                                     ofDate:[NSDate date]
                                                                    options:0];
        
        fitnessStartDate = startDate;
        [self saveSevenDayFitnessStartDate:fitnessStartDate];
        
        APCAppDelegate *appDelegate = (APCAppDelegate *)[[UIApplication sharedApplication] delegate];
        appDelegate.sevenDayFitnessAllocationData = [[APCFitnessAllocation alloc] initWithAllocationStartDate:fitnessStartDate];
        [appDelegate.sevenDayFitnessAllocationData startDataCollection];
    }
    
    self.allocationStartDate = fitnessStartDate;
    
    return fitnessStartDate;
}

- (void)saveSevenDayFitnessStartDate:(NSDate *)startDate
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:startDate forKey:kSevenDayFitnessStartDateKey];
    
    [defaults synchronize];
}

#pragma mark - Fitness Allocation Delegate

- (void)datasetDidUpdate:(NSNotification *)notif
{
    [self handleDays:self.segmentDays];
    
    NSLog(@"Received notification: %@", notif.userInfo);
}

- (void)refreshAllocation:(NSInteger)segmentIndex
{
    if (segmentIndex == kYesterdaySegmentIndex && self.previouslySelectedSegment == kTodaySegmentIndex) {
        self.chartView.shouldDrawClockwise = NO;
    } else if (segmentIndex == kWeekSegmentIndex && self.previouslySelectedSegment == kTodaySegmentIndex) {
        self.chartView.shouldDrawClockwise = YES;
    } else if (self.previouslySelectedSegment == kYesterdaySegmentIndex) {
        self.chartView.shouldDrawClockwise = YES;
    } else if (self.previouslySelectedSegment == kWeekSegmentIndex) {
        self.chartView.shouldDrawClockwise = NO;
    }
    
    self.previouslySelectedSegment = segmentIndex;
    
    [self.chartView layoutSubviews];
}

#pragma mark - PieGraphView Delegates

-(NSInteger)numberOfSegmentsInPieGraphView:(APCPieGraphView *) __unused pieGraphView
{
    return [self.allocationDataset count];
}

- (UIColor *)pieGraphView:(APCPieGraphView *) __unused pieGraphView colorForSegmentAtIndex:(NSInteger)index
{
    return [[self.allocationDataset valueForKey:kDatasetSegmentColorKey] objectAtIndex:index];
}

- (NSString *)pieGraphView:(APCPieGraphView *) __unused pieGraphView titleForSegmentAtIndex:(NSInteger)index
{
    return [[self.allocationDataset valueForKey:kDatasetSegmentKey] objectAtIndex:index];
}

- (CGFloat)pieGraphView:(APCPieGraphView *) __unused pieGraphView valueForSegmentAtIndex:(NSInteger)index
{
    return [[[self.allocationDataset valueForKey:kSegmentSumKey] objectAtIndex:index] floatValue];
}

- (IBAction)resetTaskStartDate:(id) __unused sender {
    
    [[UIView appearanceWhenContainedIn:[UIAlertController class], nil] setTintColor:[UIColor appPrimaryColor]];
    
    UIAlertController *alertContorller = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"Resetting your 7 Day Assessment will clear all recorded data from the week.", @"") preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *withdrawAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Continue", @"") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * __unused action) {
        [self reset];
    }];
    [alertContorller addAction:withdrawAction];
    
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction * __unused action) {
        
    }];
    
    [alertContorller addAction:cancelAction];
    
    [self.navigationController presentViewController:alertContorller animated:YES completion:nil];

}

- (void)reset
{
    //Updating the start date of the task.
    [self saveSevenDayFitnessStartDate: [[NSDate date] startOfDay]];

    //Calling the motion history reporter to retrieve and update the data for core activity. This triggers a series of notifications that lead to the pie graph being drawn again here.
    APCMotionHistoryReporter *reporter = [APCMotionHistoryReporter sharedInstance];
    
    [reporter startMotionCoProcessorDataFrom:[[NSDate date] startOfDay] andEndDate:[[NSDate date] endOfDay] andNumberOfDays:1];

    [self.segmentDays setEnabled:NO forSegmentAtIndex:0];
    [self.segmentDays setEnabled:NO forSegmentAtIndex:2];
}

- (IBAction)infoIconHandler:(id) __unused sender {
    UIImage *blurredImage = [self.view blurredSnapshotDark];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.customSurveylearnMoreView = imageView;
    imageView.alpha = 0;
    [imageView setBounds:[UIScreen mainScreen].bounds];
    
    [self.view addSubview:imageView];
    imageView.image = blurredImage;
    
    [UIView animateWithDuration:0.2 animations:^{
        imageView.alpha = 1;
    }];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeLearnMore:)];
    [imageView setUserInteractionEnabled:YES];
    
    tapGesture.delegate = self;
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.numberOfTouchesRequired = 1;
    tapGesture.cancelsTouchesInView = NO;
    
    [imageView addGestureRecognizer:tapGesture];
    
    UIView *learnMoreBubble = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [learnMoreBubble setBackgroundColor:[UIColor whiteColor]];
    learnMoreBubble.layer.cornerRadius = 5;
    learnMoreBubble.layer.masksToBounds = YES;
    
    [imageView addSubview:learnMoreBubble];
    
    [learnMoreBubble setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    // SET THE WIDTH
    [imageView addConstraint:[NSLayoutConstraint
                              constraintWithItem:learnMoreBubble
                              attribute:NSLayoutAttributeWidth
                              relatedBy:NSLayoutRelationEqual
                              toItem:imageView
                              attribute:NSLayoutAttributeWidth
                              multiplier:0.9
                              constant:0.0]];
    
    [imageView addConstraint:[NSLayoutConstraint
                              constraintWithItem:learnMoreBubble
                              attribute:NSLayoutAttributeHeight
                              relatedBy:NSLayoutRelationEqual
                              toItem:imageView
                              attribute:NSLayoutAttributeHeight
                              multiplier:0.5
                              constant:0.0]];
    
    [imageView addConstraint:[NSLayoutConstraint
                              constraintWithItem:learnMoreBubble
                              attribute:NSLayoutAttributeCenterY
                              relatedBy:NSLayoutRelationEqual
                              toItem:imageView
                              attribute:NSLayoutAttributeCenterY
                              multiplier:0.6
                              constant:0.0]];
    
    [imageView addConstraint:[NSLayoutConstraint
                              constraintWithItem:learnMoreBubble
                              attribute:NSLayoutAttributeCenterX
                              relatedBy:NSLayoutRelationEqual
                              toItem:imageView
                              attribute:NSLayoutAttributeCenterX
                              multiplier:1
                              constant:0.0]];
    
    UILabel *textView = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, learnMoreBubble.bounds.size.width, 100.0)];
    [learnMoreBubble addSubview:textView];
    
    [textView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [learnMoreBubble addConstraint:[NSLayoutConstraint
                                    constraintWithItem:textView
                                    attribute:NSLayoutAttributeWidth
                                    relatedBy:NSLayoutRelationEqual
                                    toItem:learnMoreBubble
                                    attribute:NSLayoutAttributeWidth
                                    multiplier:0.85
                                    constant:0.0]];
    
    [learnMoreBubble addConstraint:[NSLayoutConstraint
                                    constraintWithItem:textView
                                    attribute:NSLayoutAttributeHeight
                                    relatedBy:NSLayoutRelationEqual
                                    toItem:learnMoreBubble
                                    attribute:NSLayoutAttributeHeight
                                    multiplier:0.9
                                    constant:0.0]];
    
    [learnMoreBubble addConstraint:[NSLayoutConstraint
                                    constraintWithItem:textView
                                    attribute:NSLayoutAttributeCenterY
                                    relatedBy:NSLayoutRelationEqual
                                    toItem:learnMoreBubble
                                    attribute:NSLayoutAttributeCenterY
                                    multiplier:1
                                    constant:0.0]];
    
    [learnMoreBubble addConstraint:[NSLayoutConstraint
                                    constraintWithItem:textView
                                    attribute:NSLayoutAttributeCenterX
                                    relatedBy:NSLayoutRelationEqual
                                    toItem:learnMoreBubble
                                    attribute:NSLayoutAttributeCenterX
                                    multiplier:1
                                    constant:0.0]];
    
    textView.text =NSLocalizedString( kLearnMoreString, nil);
    
    textView.textColor = [UIColor blackColor];
    [textView setFont:[UIFont fontWithName:@"HelveticaNeue" size:kRegularFontSize]];
    textView.numberOfLines = 0;
    textView.adjustsFontSizeToFitWidth  = YES;
    
}



- (void)removeLearnMore:(id) __unused sender {
    [UIView animateWithDuration:0.2 animations:^{
        self.customSurveylearnMoreView.alpha = 0;
    } completion:^(BOOL __unused finished) {
        [self.customSurveylearnMoreView removeFromSuperview];
    }];
}

@end
