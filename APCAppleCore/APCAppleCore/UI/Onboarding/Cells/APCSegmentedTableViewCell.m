//
//  APCSegmentedTableViewCell.m
//  APCAppleCore
//
//  Created by Ramsundar Shandilya on 10/14/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCSegmentedTableViewCell.h"
#import "UIColor+APCAppearance.h"

@interface APCSegmentedTableViewCell ()<APCSegmentedButtonDelegate>


@end

@implementation APCSegmentedTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
    self.segmentedButton = [[APCSegmentedButton alloc] initWithButtons:@[self.maleButton, self.femaleButton, self.otherButton] normalColor:[UIColor appSecondaryColor3] highlightColor:[UIColor appSecondaryColor1]];
    [self.segmentedButton setSelectedIndex:0];
    self.segmentedButton.delegate = self;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) segmentedButtonPressed:(UIButton*) button selectedIndex: (NSInteger) selectedIndex
{
    self.selectedSegmentIndex = selectedIndex;
    
    if ([self.delegate respondsToSelector:@selector(segmentedTableViewcell:didSelectSegmentAtIndex:)]) {
        [self.delegate segmentedTableViewcell:self didSelectSegmentAtIndex:self.selectedSegmentIndex];
    }
}

- (void)setSelectedSegmentIndex:(NSInteger)selectedSegmentIndex
{
    _selectedSegmentIndex = selectedSegmentIndex;
    
    [self.segmentedButton setSelectedIndex:selectedSegmentIndex];
}

@end
