//
//  APCSegmentedTableViewCell.h
//  APCAppleCore
//
//  Created by Ramsundar Shandilya on 10/14/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APCSegmentedButton.h"

static NSString * const kAPCSegmentedTableViewCellIdentifier = @"APCSegmentedTableViewCell";

@protocol APCSegmentedTableViewCellDelegate;

@interface APCSegmentedTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *maleButton;
@property (weak, nonatomic) IBOutlet UIButton *femaleButton;
@property (weak, nonatomic) IBOutlet UIButton *otherButton;

@property (nonatomic, strong) APCSegmentedButton *segmentedButton;

@property (nonatomic) NSInteger selectedSegmentIndex;

@property (nonatomic, weak) id <APCSegmentedTableViewCellDelegate> delegate;

@end

@protocol APCSegmentedTableViewCellDelegate <NSObject>

- (void)segmentedTableViewCell:(APCSegmentedTableViewCell *)cell didSelectSegmentAtIndex:(NSInteger)index;

@end
