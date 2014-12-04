// 
//  APCTintedTableViewCell.h 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import <UIKit/UIKit.h>

FOUNDATION_EXPORT NSString *const kAPCTintedTableViewCellIdentifier;

@interface APCTintedTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UILabel *textLabel;

@property (strong, nonatomic) UIColor *tintColor;

@end
