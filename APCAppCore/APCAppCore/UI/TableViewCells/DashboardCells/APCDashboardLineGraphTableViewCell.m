// 
//  APCDashboardLineGraphTableViewCell.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "APCDashboardLineGraphTableViewCell.h"

@implementation APCDashboardLineGraphTableViewCell

@synthesize tintColor = _tintColor;

- (void)awakeFromNib {
    
    [self.resizeButton setImage:[[UIImage imageNamed:@"expand_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
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
    for (UIView *subview in self.subviews) {
        [subview layoutSubviews];
    }
}

- (void)setTintColor:(UIColor *)tintColor
{
    _tintColor = tintColor;
    [self.resizeButton.imageView setTintColor:tintColor];
}
@end
