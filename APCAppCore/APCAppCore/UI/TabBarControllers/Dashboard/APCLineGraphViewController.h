//
//  APCLineGraphViewController.h
//  APCAppCore
//
//  Created by Ramsundar Shandilya on 11/16/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APCGraph.h"
#import "APCTableViewItem.h"

@interface APCLineGraphViewController : UIViewController

@property (weak, nonatomic) IBOutlet APCLineGraphView *graphView;

@property (nonatomic, strong) APCTableViewDashboardGraphItem *graphItem;

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@property (weak, nonatomic) IBOutlet UISwitch *compareSwitch;

@property (weak, nonatomic) IBOutlet UILabel *compareLabel;

@property (weak, nonatomic) IBOutlet UIButton *collapseButton;

- (IBAction)collapse:(id)sender;

@property (weak, nonatomic) IBOutlet UISwitch *toggleSwitch;
@end
