//
//  APCDashboardMoreInfoViewController.h
//  AppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface APCDashboardMoreInfoViewController : UIViewController

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cellHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cellTopConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *cellSnapshotImageView;

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIImageView *bubbleImageView;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descriptionHeightConstraint;

@property (strong, nonatomic) UIView *blurredView;
@property (strong, nonatomic) UIImage *snapshotImage;
@property (nonatomic) CGRect cellRect;
@property (strong, nonatomic) NSString *info;

@end
