//
//  APCSegmentedTableViewCell.m
//  APCAppleCore
//
//  Created by Ramsundar Shandilya on 10/14/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCSegmentedTableViewCell.h"
#import "APCSegmentControl.h"

@implementation APCSegmentedTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
    self.segmentControl = [APCSegmentControl new];
    [self.segmentControl addTarget:self action:@selector(segmentIndexChanged) forControlEvents:UIControlEventValueChanged];
    [self.contentView addSubview:self.segmentControl];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) segmentIndexChanged {
    if ([self.delegate respondsToSelector:@selector(segmentedTableViewcell:didSelectSegmentAtIndex:)]) {
        [self.delegate segmentedTableViewcell:self didSelectSegmentAtIndex:self.segmentControl.selectedSegmentIndex];
    }
}

- (void) setSegments:(NSArray *)segments selectedIndex:(NSInteger)selectedIndex
{
    [self.segmentControl removeAllSegments];
    
    for (int i = 0; i < segments.count; i++) {
        [self.segmentControl insertSegmentWithTitle:segments[i] atIndex:i animated:NO];
    }
    
    if (selectedIndex >= 0 && selectedIndex < segments.count) {
        [self.segmentControl setSelectedSegmentIndex:selectedIndex];
    }
}

@end
