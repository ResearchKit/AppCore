// 
//  APCTintedTableViewCell.h 
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//
 
#import <UIKit/UIKit.h>

FOUNDATION_EXPORT NSString *const kAPCTintedTableViewCellIdentifier;

@interface APCTintedTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UILabel *textLabel;

@property (strong, nonatomic) UIColor *tintColor;

@end
