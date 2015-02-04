//
//  APCDashboardTableViewCell.h
//  AppCore
//
//  Copyright (c) 2015 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class APCDashboardTableViewCell;

@protocol APCDashboardTableViewCellDelegate <NSObject>

@optional
- (void)dashboardTableViewCellDidTapExpand:(APCDashboardTableViewCell *)cell;

- (void)dashboardTableViewCellDidTapMoreInfo:(APCDashboardTableViewCell *)cell;

@end

@interface APCDashboardTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *tintView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *resizeButton;
@property (weak, nonatomic) IBOutlet UIButton *infoButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelWidthConstraint;
@property (strong, nonatomic) UIColor *tintColor;
@property (strong, nonatomic) NSString *title;

@property (weak, nonatomic) id <APCDashboardTableViewCellDelegate> delegate;

- (IBAction)infoTapped:(id)sender;
- (IBAction)expandTapped:(id)sender;

@end
