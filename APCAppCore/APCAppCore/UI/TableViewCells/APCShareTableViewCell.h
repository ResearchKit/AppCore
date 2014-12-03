//
//  APCShareTableViewCell.h
//  APCAppCore
//
//  Created by Ramsundar Shandilya on 10/30/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

FOUNDATION_EXPORT NSString * const kAPCShareTableViewCellIdentifier;

@interface APCShareTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UILabel *textLabel;

@end
