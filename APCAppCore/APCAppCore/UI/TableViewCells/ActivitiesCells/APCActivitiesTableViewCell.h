//
//  APCActivitiesTableViewCell.h
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APCConfirmationView.h"

@interface APCActivitiesTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet APCConfirmationView *confirmationView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end
