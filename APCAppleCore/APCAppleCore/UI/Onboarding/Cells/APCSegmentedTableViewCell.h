//
//  APCSegmentedTableViewCell.h
//  APCAppleCore
//
//  Created by Ramsundar Shandilya on 10/14/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * const kAPCSegmentedTableViewCellIdentifier = @"APCSegmentedTableViewCell";

@class APCSegmentControl;

@protocol APCSegmentedTableViewCellDelegate;

@interface APCSegmentedTableViewCell : UITableViewCell

@property (nonatomic, strong) APCSegmentControl *segmentControl;

@property (nonatomic, weak) id <APCSegmentedTableViewCellDelegate> delegate;

- (void) setSegments:(NSArray *)segments selectedIndex:(NSInteger)selectedIndex;

@end

@protocol APCSegmentedTableViewCellDelegate <NSObject>

- (void)segmentedTableViewcell:(APCSegmentedTableViewCell *)cell didSelectSegmentAtIndex:(NSInteger)index;

@end