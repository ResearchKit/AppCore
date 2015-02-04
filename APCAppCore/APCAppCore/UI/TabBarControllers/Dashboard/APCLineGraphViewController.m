// 
//  APCLineGraphViewController.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "APCLineGraphViewController.h"
#import "UIColor+APCAppearance.h"
#import "UIFont+APCAppearance.h"
#import "UIImage+APCHelper.h"
#import "APCAppCore.h"

@interface APCLineGraphViewController ()

@end

@implementation APCLineGraphViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.graphView.tintColor = self.graphItem.tintColor;
    self.graphView.datasource = self.graphItem.graphData;
    self.graphView.landscapeMode = YES;
    
    self.titleLabel.text = self.graphItem.caption;
    self.subTitleLabel.text = self.graphItem.detailText;
    
    [self setupAppearance];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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
    [self.segmentedControl setTitleTextAttributes:@{NSFontAttributeName:[UIFont appMediumFontWithSize:19.0f], NSForegroundColorAttributeName : [UIColor appSecondaryColor1]} forState:UIControlStateSelected];
    
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

- (IBAction)collapse:(id)sender
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
                        [self.graphView layoutSubviews];
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
                        [self.graphView layoutSubviews];
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
                        [self.graphView layoutSubviews];
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
                        [self.graphView layoutSubviews];
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
                        [self.graphView layoutSubviews];
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
                        [self.graphView layoutSubviews];
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
