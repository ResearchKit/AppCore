//
//  APCAddressTableViewCell.h
//  APCAppleCore
//
//  Created by Ramsundar Shandilya on 12/2/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

FOUNDATION_EXPORT NSString * const kAPCAddressTableViewCellIdentifier;

@interface APCAddressTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UILabel *textLabel;

@end
