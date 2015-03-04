// 
//  APCSegmentedTableViewCell.h 
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
//  Copyright (c) 2014 Apple Inc. All rights reserved.
// 
 
#import <UIKit/UIKit.h>
#import "APCSegmentedButton.h"

FOUNDATION_EXPORT NSString * const kAPCSegmentedTableViewCellIdentifier;

@protocol APCSegmentedTableViewCellDelegate;

@interface APCSegmentedTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *maleButton;
@property (weak, nonatomic) IBOutlet UIButton *femaleButton;

@property (nonatomic, strong) APCSegmentedButton *segmentedButton;

@property (nonatomic) NSInteger selectedSegmentIndex;

@property (nonatomic, weak) id <APCSegmentedTableViewCellDelegate> delegate;

@end

@protocol APCSegmentedTableViewCellDelegate <NSObject>

- (void)segmentedTableViewCell:(APCSegmentedTableViewCell *)cell didSelectSegmentAtIndex:(NSInteger)index;

@end
