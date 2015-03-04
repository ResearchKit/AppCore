// 
//  APCDashboardMessageTableViewCell.m 
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
//
 
#import "APCDashboardMessageTableViewCell.h"
#import "UIColor+APCAppearance.h"
#import "UIFont+APCAppearance.h"

NSString * const kAPCDashboardMessageTableViewCellIdentifier = @"APCDashboardMessageTableViewCell";

@implementation APCDashboardMessageTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self setupAppearance];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setupAppearance
{
    self.titleLabel.font = [UIFont appLightFontWithSize:19.0f];
    self.titleLabel.textColor = [UIColor appSecondaryColor1];
    
    self.messageLabel.font = [UIFont appLightFontWithSize:16.0f];
    self.messageLabel.textColor = [UIColor appSecondaryColor2];
}

- (void)setType:(APCDashboardMessageType)type
{
    _type = type;
    
    switch (type) {
        case kAPCDashboardMessageTypeAlert:
        {
            self.titleLabel.text = NSLocalizedString(@"Alert",nil);
        }
            break;
        case kAPCDashboardMessageTypeInsight:
        {
            self.titleLabel.text = NSLocalizedString(@"Insight", nil);
        }
            break;
        default:{
            NSAssert(0, @"Invalid Cell Type");
        }
            break;
    }
}

@end
