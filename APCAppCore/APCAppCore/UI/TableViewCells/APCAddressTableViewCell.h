// 
//  APCAddressTableViewCell.h 
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
//
 
#import <UIKit/UIKit.h>

FOUNDATION_EXPORT NSString * const kAPCAddressTableViewCellIdentifier;

@interface APCAddressTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UILabel *textLabel;

@end
