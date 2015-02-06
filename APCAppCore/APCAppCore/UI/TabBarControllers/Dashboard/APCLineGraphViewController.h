// 
//  APCLineGraphViewController.h 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import <UIKit/UIKit.h>
#import "APCGraph.h"
#import "APCTableViewItem.h"

@interface APCLineGraphViewController : UIViewController

@property (weak, nonatomic) IBOutlet APCLineGraphView *graphView;

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
@end
