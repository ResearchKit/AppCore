//
//  APCTintedTableViewCell.h
//  APCAppCore
//
//  Created by Ramsundar Shandilya on 11/9/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

FOUNDATION_EXPORT NSString *const kAPCTintedTableViewCellIdentifier;

@interface APCTintedTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UILabel *textLabel;

@property (strong, nonatomic) UIColor *tintColor;

@end
