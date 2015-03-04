// 
//  APCDefaultTableViewCell.m 
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//
 
#import "APCDefaultTableViewCell.h"

NSString * const kAPCDefaultTableViewCellIdentifier = @"APCDefaultTableViewCell";

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
    _type = type;

    if (type == kAPCDefaultTableViewCellTypeLeft) {
        self.textLabelWidthConstraint.constant = 91;
        self.detailTextLabel.textAlignment = NSTextAlignmentLeft;
    } else {
        self.textLabelWidthConstraint.constant = 180;
        self.detailTextLabel.textAlignment = NSTextAlignmentRight;
    }
    
    [self layoutIfNeeded];
}

@end
