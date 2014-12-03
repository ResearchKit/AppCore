//
//  APCShareTableViewCell.m
//  APCAppleCore
//
//  Created by Ramsundar Shandilya on 10/30/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCShareTableViewCell.h"
#import "UIColor+APCAppearance.h"
#import "UIFont+APCAppearance.h"

NSString * const kAPCShareTableViewCellIdentifier = @"ShareTableViewCellIdentifier";

@implementation APCShareTableViewCell

@synthesize imageView = _imageView;
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
    [self.textLabel setTextColor:[UIColor appSecondaryColor1]];
    [self.textLabel setFont:[UIFont appRegularFontWithSize:16.0f]];
}

@end
