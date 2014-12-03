//
//  APCCheckTableViewCell.h
//  APCAppCore
//
//  Created by Ramsundar Shandilya on 11/9/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APCConfirmationView.h"

FOUNDATION_EXPORT NSString *const kAPCCheckTableViewCellIdentifier;

@interface APCCheckTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet APCConfirmationView *confirmationView;

@end
