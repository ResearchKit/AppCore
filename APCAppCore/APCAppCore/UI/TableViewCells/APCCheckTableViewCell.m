// 
//  APCCheckTableViewCell.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "APCCheckTableViewCell.h"
#import "UIColor+APCAppearance.h"
#import "UIFont+APCAppearance.h"

NSString *const kAPCCheckTableViewCellIdentifier = @"APCCheckTableViewCell";

@implementation APCCheckTableViewCell

@synthesize textLabel = _textLabel;

- (void)awakeFromNib {
    // Initialization code
    
    [self setupAppearance];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setupAppearance
{
    [self.textLabel setFont:[UIFont appRegularFontWithSize:14.0f]];
    [self.textLabel setTextColor:[UIColor appSecondaryColor1]];
}

@end
