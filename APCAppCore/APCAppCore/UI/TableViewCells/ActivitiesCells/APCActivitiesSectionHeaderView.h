//
//  APCActivitiesSectionHeaderView.h
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

FOUNDATION_EXPORT NSString * const kAPCActivitiesSectionHeaderViewIdentifier;

@interface APCActivitiesSectionHeaderView : UITableViewHeaderFooterView

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;

@end
