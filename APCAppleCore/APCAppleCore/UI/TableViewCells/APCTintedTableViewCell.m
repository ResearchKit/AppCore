//
//  APCTintedTableViewCell.m
//  APCAppleCore
//
//  Created by Ramsundar Shandilya on 11/9/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCTintedTableViewCell.h"
#import "UIColor+APCAppearance.h"
#import "UIFont+APCAppearance.h"

@interface APCTintedTableViewCell ()

@property (weak, nonatomic) IBOutlet UIView *tintView;

@end

@implementation APCTintedTableViewCell

@synthesize textLabel = _textLabel;
@synthesize tintColor = _tintColor;
@synthesize imageView = _imageView;

- (void)awakeFromNib {
    
    [self setupAppearance];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setupAppearance
{
    self.textLabel.font = [UIFont appRegularFontWithSize:16];
    self.textLabel.textColor = [UIColor appSecondaryColor1];
}

- (void)setTintColor:(UIColor *)tintColor
{
    _tintColor = tintColor;
    self.tintView.backgroundColor = tintColor;
    self.imageView.tintColor = tintColor;
}

@end
