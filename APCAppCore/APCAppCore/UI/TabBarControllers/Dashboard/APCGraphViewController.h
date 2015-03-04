//
//  APCLineGraphViewController.h 
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//
 
#import <UIKit/UIKit.h>
#import "APCGraph.h"
#import "APCTableViewItem.h"

@interface APCGraphViewController : UIViewController

@property (weak, nonatomic) IBOutlet APCLineGraphView *lineGraphView;
@property (weak, nonatomic) IBOutlet APCDiscreteGraphView *discreteGraphView;

@property (nonatomic, strong) APCTableViewDashboardGraphItem *graphItem;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelWidthConstraint;

@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;

@property (weak, nonatomic) IBOutlet UIView *tintView;

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@property (weak, nonatomic) IBOutlet UISwitch *compareSwitch;

@property (weak, nonatomic) IBOutlet UILabel *compareLabel;

@property (weak, nonatomic) IBOutlet UIButton *collapseButton;

- (IBAction)collapse:(id)sender;

@property (weak, nonatomic) IBOutlet UISwitch *toggleSwitch;

@property (weak, nonatomic) IBOutlet UIImageView *averageImageView;

@end
