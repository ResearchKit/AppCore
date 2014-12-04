// 
//  APCSwitchTableViewCell.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "APCSwitchTableViewCell.h"

NSString *const kAPCSwitchCellIdentifier = @"APCSwitchTableViewCell";

@implementation APCSwitchTableViewCell

@synthesize textLabel = _textLabel;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)switchChanged:(UISwitch *)sender
{
    if ([self.delegate respondsToSelector:@selector(switchTableViewCell:switchValueChanged:)]) {
        [self.delegate switchTableViewCell:self switchValueChanged:sender.on];
    }
}

@end
