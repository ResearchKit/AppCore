// 
//  APCLineGraphViewController.m 
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//
 
#import "APCGraphViewController.h"
#import "UIColor+APCAppearance.h"
#import "UIFont+APCAppearance.h"
#import "UIImage+APCHelper.h"
#import "APCAppCore.h"

@interface APCGraphViewController ()

@end

@implementation APCGraphViewController

- (void)viewDidLoad {
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

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    CGSize textSize = [self.titleLabel.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGRectGetHeight(self.titleLabel.frame)) options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.titleLabel.font} context:nil].size;
    
    self.titleLabelWidthConstraint.constant = textSize.width + 2;
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
    APCBaseGraphView *graphView;
    
    if (self.graphItem.graphType == kAPCDashboardGraphTypeLine) {
        graphView = self.lineGraphView;
    } else if (self.graphItem.graphType == kAPCDashboardGraphTypeDiscrete) {
        graphView = self.discreteGraphView;
    }
    
    APCSpinnerViewController *spinnerController = [[APCSpinnerViewController alloc] init];
    spinnerController.landscape = YES;
    [self presentViewController:spinnerController animated:YES completion:nil];
    
    switch (sender.selectedSegmentIndex) {
        case 0:
        {
            //Last 5 days
            [self.graphItem.graphData updatePeriodForDays:-5 groupBy:APHTimelineGroupDay withCompletionHandler:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [spinnerController dismissViewControllerAnimated:YES completion:^{
                        [graphView layoutSubviews];
                        [graphView refreshGraph];
                    }];
                    
                });
            }];
        }
            break;
        case 1:
        {
            //Last 1 week (7 days)
            [self.graphItem.graphData updatePeriodForDays:-7 groupBy:APHTimelineGroupDay withCompletionHandler:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [spinnerController dismissViewControllerAnimated:YES completion:^{
                        [graphView layoutSubviews];
                        [graphView refreshGraph];
                    }];
                });
            }];
        }
            break;
        case 2:
        {
            //Last 1 Month (30 days)
            [self.graphItem.graphData updatePeriodForDays:-30 groupBy:APHTimelineGroupWeek withCompletionHandler:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [spinnerController dismissViewControllerAnimated:YES completion:^{
                        [graphView layoutSubviews];
                        [graphView refreshGraph];
                    }];
                });
            }];
        }
            break;
        case 3:
        {
            //Last 3 Months (90 days)
            [self.graphItem.graphData updatePeriodForDays:-90 groupBy:APHTimelineGroupWeek withCompletionHandler:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [spinnerController dismissViewControllerAnimated:YES completion:^{
                        [graphView layoutSubviews];
                        [graphView refreshGraph];
                    }];
                });
            }];
        }
            break;
        case 4:
        {
            //Last 6 Months (180 days)
            [self.graphItem.graphData updatePeriodForDays:-180 groupBy:APHTimelineGroupMonth withCompletionHandler:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [spinnerController dismissViewControllerAnimated:YES completion:^{
                        [graphView layoutSubviews];
                        [graphView refreshGraph];
                    }];
                });
            }];
        }
            break;
        case 5:
        {
            //Last 1 year (365 days)
            [self.graphItem.graphData updatePeriodForDays:-365 groupBy:APHTimelineGroupMonth withCompletionHandler:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [spinnerController dismissViewControllerAnimated:YES completion:^{
                        [graphView layoutSubviews];
                        [graphView refreshGraph];
                    }];
                });
            }];
        }
            break;
        default:
            break;
    }
}

@end
