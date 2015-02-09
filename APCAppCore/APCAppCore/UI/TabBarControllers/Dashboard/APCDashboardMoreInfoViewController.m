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

static const CGFloat kDescriptionLabelTopConstant = 12.0f;
static const CGFloat kDescriptionLabelBottomConstant = 30.0f;

@interface APCDashboardMoreInfoViewController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewVerticalConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descriptionTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descriptionBottomConstraint;

@end

@implementation APCDashboardMoreInfoViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self setupAppearance];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.view bringSubviewToFront:self.cellSnapshotImageView];
    [self.view bringSubviewToFront:self.containerView];
    
    self.cellSnapshotImageView.image = self.snapshotImage;
    
    self.descriptionLabel.text = self.info;
    self.backgroundImageView.image = self.blurredImage;
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [UIView animateWithDuration:0.2 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.containerView.transform = CGAffineTransformMakeScale(1, 1);
        self.containerView.alpha = 1.0;
    } completion:^(BOOL finished) {
        
    }];
}
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    self.cellTopConstraint.constant = CGRectGetMinY(self.cellRect) - 20;
    self.cellHeightConstraint.constant = CGRectGetHeight(self.cellRect);
    
    CGSize textSize = [self.descriptionLabel.text boundingRectWithSize:CGSizeMake(CGRectGetWidth(self.descriptionLabel.frame), CGFLOAT_MAX) options:(NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName:self.descriptionLabel.font} context:nil].size;
    self.descriptionHeightConstraint.constant = textSize.height + kBubbleInnerPadding;
    
    if (self.shouldInvertBubble) {
        
        self.containerViewVerticalConstraint.active = NO;
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.containerView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.cellSnapshotImageView attribute:NSLayoutAttributeBottom multiplier:1 constant:2]];
        
        self.descriptionTopConstraint.constant = kDescriptionLabelBottomConstant;
        self.descriptionBottomConstraint.constant = kDescriptionLabelTopConstant;
        
        self.bubbleImageView.image = [[UIImage imageNamed:@"info_bubble_upsidedown"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 30, 10) resizingMode:UIImageResizingModeStretch];
        
//        self.containerView.layer.anchorPoint = CGPointMake(0.5, 0);
        self.containerView.layer.transform = CATransform3DTranslate(self.containerView.layer.transform, 0, -CGRectGetHeight(self.containerView.layer.bounds)/2, 0);
    }
    
    [self.view setNeedsLayout];
}

- (void)setupAppearance
{
    self.descriptionLabel.font = [UIFont appRegularFontWithSize:14.0f];
    self.descriptionLabel.textColor = [UIColor appSecondaryColor2];
    
    self.bubbleImageView.image = [[UIImage imageNamed:@"info_bubble_upright"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 30, 10) resizingMode:UIImageResizingModeStretch];
    
//    self.containerView.layer.anchorPoint = CGPointMake(0.5, 1.0);
    self.containerView.alpha = 0;
    self.containerView.transform = CGAffineTransformMakeScale(0.01, 0.01);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.containerView.transform = CGAffineTransformMakeScale(0.01, 0.01);
        self.containerView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self dismiss];
    }];
}

- (void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
