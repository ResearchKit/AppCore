//
//  APHActivitiesTableViewCell.m
//  Parkinson
//
//  Created by Henry McGilton on 8/20/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCActivitiesTableViewCell.h"
#import "APCAppleCore.h"

static NSInteger kNumberOfLinesForTypeDefault  = 2;
static NSInteger kNumberOfLinesForTypeSubtitle = 1;

static NSInteger kConfirmationViewTag = 100;
static NSInteger kTitleLabelTag = 200;
static NSInteger kSubtitleLabelTag = 300;
static NSInteger kDurationLabelTag = 400;

@interface APCActivitiesTableViewCell()

@end

@implementation APCActivitiesTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.confirmationView = (APCConfirmationView*) [self viewWithTag:kConfirmationViewTag];
    self.titleLabel = (UILabel*) [self viewWithTag:kTitleLabelTag];
    self.subTitleLabel = (UILabel*) [self viewWithTag:kSubtitleLabelTag];
    self.durationLabel = (UILabel*) [self viewWithTag:kDurationLabelTag];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    return [super initWithStyle:style reuseIdentifier:reuseIdentifier];
}

@synthesize completed = _completed;

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (BOOL)isCompleted
{
    return  _completed;
}

- (void)setCompleted:(BOOL)aCompleted
{
    if (_completed != aCompleted) {
        _completed = aCompleted;
        self.confirmationView.completed = aCompleted;
    }
}

- (void)setType:(APHActivitiesTableViewCellType)type
{
    _type = type;
    
    switch (type) {
        case kActivitiesTableViewCellTypeDefault:
        {
            self.titleLabel.numberOfLines = kNumberOfLinesForTypeDefault;
            self.subTitleLabel.hidden = YES;
        }
            break;
        case kActivitiesTableViewCellTypeSubtitle:
        {
            self.titleLabel.numberOfLines = kNumberOfLinesForTypeSubtitle;
            self.subTitleLabel.hidden = NO;
        }
            break;
        default:
            break;
    }
    
    [self setNeedsLayout];
}

@end
