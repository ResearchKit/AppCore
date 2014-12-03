//
//  APCSegmentedTableViewCell.m
//  APCAppleCore
//
//  Created by Ramsundar Shandilya on 10/14/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCSegmentedTableViewCell.h"
#import "UIColor+APCAppearance.h"
#import "UIFont+APCAppearance.h"

NSString * const kAPCSegmentedTableViewCellIdentifier = @"APCSegmentedTableViewCell";

@interface APCSegmentedTableViewCell ()<APCSegmentedButtonDelegate>

@end

@implementation APCSegmentedTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
    self.segmentedButton = [[APCSegmentedButton alloc] initWithButtons:@[self.maleButton, self.femaleButton, self.otherButton] normalColor:[UIColor appSecondaryColor3] highlightColor:[UIColor appSecondaryColor1]];
    [self.segmentedButton setSelectedIndex:0];
    self.segmentedButton.delegate = self;
    
    [self setupAppearance];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setupAppearance
{
    [self.maleButton.titleLabel setFont:[UIFont appRegularFontWithSize:16.0]];
    [self.femaleButton.titleLabel setFont:[UIFont appRegularFontWithSize:16.0]];
    [self.otherButton.titleLabel setFont:[UIFont appRegularFontWithSize:16.0]];
}

- (void) segmentedButtonPressed:(UIButton*) button selectedIndex: (NSInteger) selectedIndex
{
    self.selectedSegmentIndex = selectedIndex;
    
    if ([self.delegate respondsToSelector:@selector(segmentedTableViewCell:didSelectSegmentAtIndex:)]) {
        [self.delegate segmentedTableViewCell:self didSelectSegmentAtIndex:self.selectedSegmentIndex];
    }
}

- (void)setSelectedSegmentIndex:(NSInteger)selectedSegmentIndex
{
    _selectedSegmentIndex = selectedSegmentIndex;
    
    [self.segmentedButton setSelectedIndex:selectedSegmentIndex];
}

@end
