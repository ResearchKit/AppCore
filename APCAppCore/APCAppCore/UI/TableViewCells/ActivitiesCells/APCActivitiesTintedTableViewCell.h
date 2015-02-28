//
//  APCActivitiesTintedTableViewCell.h
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APCActivitiesTableViewCell.h"
#import "APCBadgeLabel.h"

FOUNDATION_EXPORT NSString * const kAPCActivitiesTintedTableViewCellIdentifier;

typedef NS_ENUM(NSUInteger, APCTintColorType) {
    kAPCTintColorTypeGreen,
    kAPCTintColorTypeRed,
    kAPCTintColorTypeYellow,
    kAPCTintColorTypePurple,
    kAPCTintColorTypeBlue
};

@interface APCActivitiesTintedTableViewCell : APCActivitiesTableViewCell

@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet UIView *tintView;
@property (weak, nonatomic) IBOutlet APCBadgeLabel *countLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelCenterYConstraint;

@property (strong, nonatomic) UIColor *tintColor;

@property (nonatomic) BOOL hidesSubTitle;

- (void)setupAppearance;
- (void)setupIncompleteAppearance;

@end
