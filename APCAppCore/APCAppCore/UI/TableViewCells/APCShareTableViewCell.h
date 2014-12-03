// 
//  APCShareTableViewCell.h 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import <UIKit/UIKit.h>

FOUNDATION_EXPORT NSString * const kAPCShareTableViewCellIdentifier;

@interface APCShareTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UILabel *textLabel;

@end
