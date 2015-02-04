//
//  APCDashboardMoreInfoViewController.m
//  AppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCDashboardMoreInfoViewController.h"
#import "UIFont+APCAppearance.h"
#import "UIColor+APCAppearance.h"

static const CGFloat kBubbleInnerPadding = 39.0f;

@interface APCDashboardMoreInfoViewController ()

@end

@implementation APCDashboardMoreInfoViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self setupAppearance];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    [self.view addGestureRecognizer:tapRecognizer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.view bringSubviewToFront:self.cellSnapshotImageView];
    [self.view bringSubviewToFront:self.containerView];
    
    self.cellSnapshotImageView.image = self.snapshotImage;
    
    self.descriptionLabel.text = self.info;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    self.cellTopConstraint.constant = CGRectGetMinY(self.cellRect) - 20;
    self.cellHeightConstraint.constant = CGRectGetHeight(self.cellRect);
    
    CGSize textSize = [self.descriptionLabel.text boundingRectWithSize:CGSizeMake(CGRectGetWidth(self.descriptionLabel.frame), CGFLOAT_MAX) options:(NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName:self.descriptionLabel.font} context:nil].size;
    self.descriptionHeightConstraint.constant = textSize.height + kBubbleInnerPadding;
    
    [self.view setNeedsLayout];
}

- (void)setupAppearance
{
    self.descriptionLabel.font = [UIFont appRegularFontWithSize:14.0f];
    self.descriptionLabel.textColor = [UIColor appSecondaryColor2];
    
    self.bubbleImageView.image = [[UIImage imageNamed:@"info_bubble_upright"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 30, 10) resizingMode:UIImageResizingModeStretch];
}

- (void)viewTapped:(UITapGestureRecognizer *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
