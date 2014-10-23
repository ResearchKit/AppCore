//
//  APCDetailTableViewCell.m
//  APCAppleCore
//
//  Created by Ramsundar Shandilya on 10/23/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCDefaultTableViewCell.h"

@interface APCDefaultTableViewCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textLabelWidthConstraint;

@end
@implementation APCDefaultTableViewCell

@synthesize textLabel = _textLabel;
@synthesize detailTextLabel = _detailTextLabel;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setType:(APCDefaultTableViewCellType)type
{
    if (type == kAPCDefaultTableViewCellTypeLeft) {
        self.textLabelWidthConstraint.constant = 100;
        self.detailTextLabel.textAlignment = NSTextAlignmentLeft;
    } else {
        self.textLabelWidthConstraint.constant = 192;
        self.detailTextLabel.textAlignment = NSTextAlignmentRight;
    }
    
    [self layoutIfNeeded];
}

@end
