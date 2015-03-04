// 
//  APCCheckTableViewCell.h 
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//
 
#import <UIKit/UIKit.h>
#import "APCConfirmationView.h"

FOUNDATION_EXPORT NSString *const kAPCCheckTableViewCellIdentifier;

@interface APCCheckTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet APCConfirmationView *confirmationView;

@end
