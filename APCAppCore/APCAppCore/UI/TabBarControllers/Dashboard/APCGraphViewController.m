// 
//  APCGraphViewController.m 
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
 
#import "APCGraphViewController.h"
#import "UIColor+APCAppearance.h"
#import "UIFont+APCAppearance.h"
#import "UIImage+APCHelper.h"
#import "APCAppCore.h"

@interface APCGraphViewController ()
@property (strong, nonatomic) APCSpinnerViewController *spinnerController;
@end

@implementation APCGraphViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    APCBaseGraphView *graphView;
    
    if (self.graphItem.graphType == kAPCDashboardGraphTypeLine) {
        graphView = self.lineGraphView;
        self.lineGraphView.datasource = self.graphItem.graphData;
        self.discreteGraphView.hidden = YES;
    } else if (self.graphItem.graphType == kAPCDashboardGraphTypeDiscrete) {
        graphView = self.discreteGraphView;
        self.discreteGraphView.datasource = self.graphItem.graphData;
        self.lineGraphView.hidden = YES;
    }
    
    graphView.tintColor = self.graphItem.tintColor;
    graphView.landscapeMode = YES;
    
    graphView.minimumValueImage = self.graphItem.minimumImage;
    graphView.maximumValueImage = self.graphItem.maximumImage;
    
    self.titleLabel.text = self.graphItem.caption;
    self.subTitleLabel.text = self.graphItem.detailText;
    self.legendLabel.attributedText = self.graphItem.legend;
    
    self.averageImageView.image = self.graphItem.averageImage;
    
    [self setupAppearance];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.graphItem.graphType == kAPCDashboardGraphTypeLine) {
        [self.lineGraphView refreshGraph];
    } else if (self.graphItem.graphType == kAPCDashboardGraphTypeDiscrete) {
        [self.discreteGraphView refreshGraph];
    }

    APCLogViewControllerAppeared();
}

//Ensure that the chart returns to its default period when returning to portait mode
-(void)viewWillDisappear:(BOOL)__unused animated
{
    
    [self.graphItem.graphData updatePeriodForDays:-kNumberOfDaysToDisplay groupBy:APHTimelineGroupDay];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    CGSize textSize = [self.titleLabel.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGRectGetHeight(self.titleLabel.frame)) options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.titleLabel.font} context:nil].size;
    
    self.titleLabelWidthConstraint.constant = textSize.width + 2;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

#pragma mark - Appearance

- (void)setupAppearance
{
    self.segmentedControl.tintColor = [UIColor clearColor];
    [self.segmentedControl setTitleTextAttributes:@{NSFontAttributeName:[UIFont appRegularFontWithSize:19.0f], NSForegroundColorAttributeName : [UIColor appSecondaryColor2]} forState:UIControlStateNormal];
    [self.segmentedControl setTitleTextAttributes:@{NSFontAttributeName:[UIFont appMediumFontWithSize:19.0f], NSForegroundColorAttributeName : [UIColor whiteColor]} forState:UIControlStateSelected];
    
    self.compareSwitch.onTintColor = self.graphItem.tintColor;
    
    [self.compareLabel setFont:[UIFont appLightFontWithSize:16.0f]];
    [self.compareLabel setTextColor:[UIColor appSecondaryColor2]];
    
    self.titleLabel.font = [UIFont appRegularFontWithSize:24.0f];
    self.titleLabel.textColor = self.graphItem.tintColor;
    
    self.subTitleLabel.font = [UIFont appRegularFontWithSize:16.0f];
    self.subTitleLabel.textColor = [UIColor appSecondaryColor3];
    
    [self.collapseButton setImage:[[UIImage imageNamed:@"collapse_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self.collapseButton.imageView setTintColor:self.graphItem.tintColor];
    
    self.tintView.backgroundColor = self.graphItem.tintColor;
}

#pragma mark - Orientation methods

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationLandscapeLeft;
}

- (IBAction)collapse:(id) __unused sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - IBActions

- (IBAction)segmentControlChanged:(UISegmentedControl *)sender
{
    //waiting for update notification
    self.spinnerController = [[APCSpinnerViewController alloc] init];
    _spinnerController.landscape = YES;
    [self presentViewController:_spinnerController animated:YES completion:nil];
    
    switch (sender.selectedSegmentIndex) {
        case 0:
        {
            //Last 5 days
            [self.graphItem.graphData updatePeriodForDays:-5 groupBy:APHTimelineGroupDay];
        }
            break;
        case 1:
        {
            //Last 1 week (7 days)
            [self.graphItem.graphData updatePeriodForDays:-7 groupBy:APHTimelineGroupDay];
        }
            break;
        case 2:
        {
            //Last 1 Month (30 days)
            [self.graphItem.graphData updatePeriodForDays:-30 groupBy:APHTimelineGroupWeek];
        }
            break;
        case 3:
        {
            //Last 3 Months (90 days)
            [self.graphItem.graphData updatePeriodForDays:-90 groupBy:APHTimelineGroupMonth];
        }
            break;
        case 4:
        {
            //Last 6 Months (180 days)
            [self.graphItem.graphData updatePeriodForDays:-180 groupBy:APHTimelineGroupMonth];
        }
            break;
        case 5:
        {
            //Last 1 year (365 days)
            [self.graphItem.graphData updatePeriodForDays:-365 groupBy:APHTimelineGroupMonth];
        }
            break;
        default:
            break;
    }
}

-(void)reloadCharts
{
    APCBaseGraphView *graphView;
    
    if (self.graphItem.graphType == kAPCDashboardGraphTypeLine) {
        graphView = self.lineGraphView;
    } else if (self.graphItem.graphType == kAPCDashboardGraphTypeDiscrete) {
        graphView = self.discreteGraphView;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.spinnerController) {
            [self.spinnerController dismissViewControllerAnimated:YES completion:nil];
            self.spinnerController = nil;
        }
        
        [graphView layoutSubviews];
        [graphView refreshGraph];
    });
}

#pragma mark - APCScoring Delegate

-(void)graphViewControllerShouldUpdateChartWithScoring:(APCScoring *)__unused scoring
{
    [self reloadCharts];
}

@end
