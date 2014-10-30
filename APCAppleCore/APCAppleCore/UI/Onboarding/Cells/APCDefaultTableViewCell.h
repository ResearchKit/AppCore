//
//  APCDetailTableViewCell.h
//  APCAppleCore
//
//  Created by Ramsundar Shandilya on 10/23/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * const kAPCDefaultTableViewCellIdentifier = @"APCDefaultTableViewCell";

typedef NS_ENUM(NSUInteger, APCDefaultTableViewCellType) {
    kAPCDefaultTableViewCellTypeLeft,
    kAPCDefaultTableViewCellTypeRight,
};

@interface APCDefaultTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *textLabel;

@property (weak, nonatomic) IBOutlet UILabel *detailTextLabel;

@property (nonatomic) APCDefaultTableViewCellType type;

@end
