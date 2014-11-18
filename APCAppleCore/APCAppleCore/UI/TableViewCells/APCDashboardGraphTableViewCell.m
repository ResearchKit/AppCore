//
//  APCDashboardGraphTableViewCell.m
//  APCAppleCore
//
//  Created by Ramsundar Shandilya on 11/13/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCDashboardGraphTableViewCell.h"

@implementation APCDashboardGraphTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)expandTapped:(id)sender
{
    if([self.delegate respondsToSelector:@selector(dashboardGraphViewCellDidTapExpandForCell:)]){
        [self.delegate dashboardGraphViewCellDidTapExpandForCell:self];
    }
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    for (UIView *subview in self.graphContainerView.subviews) {
        subview.frame = self.graphContainerView.bounds;
    }
}

@end
