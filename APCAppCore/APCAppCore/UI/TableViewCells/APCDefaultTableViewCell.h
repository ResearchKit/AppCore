// 
//  APCDefaultTableViewCell.h 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import <UIKit/UIKit.h>

FOUNDATION_EXPORT NSString * const kAPCDefaultTableViewCellIdentifier;

typedef NS_ENUM(NSUInteger, APCDefaultTableViewCellType) {
    kAPCDefaultTableViewCellTypeLeft,
    kAPCDefaultTableViewCellTypeRight,
};

@interface APCDefaultTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *textLabel;

@property (weak, nonatomic) IBOutlet UILabel *detailTextLabel;

@property (nonatomic) APCDefaultTableViewCellType type;

@end
