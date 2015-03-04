//
//  APCStudyOverviewVideoCollectionViewCell.m
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
//

#import "APCStudyVideoCollectionViewCell.h"
#import "UIColor+APCAppearance.h"
#import "UIFont+APCAppearance.h"

NSString * const kAPCStudyVideoCollectionViewCellIdentifier = @"APCStudyVideoCollectionViewCell";

@implementation APCStudyVideoCollectionViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setupAppearance];
}

- (void)setupAppearance
{
    self.titleLabel.textColor = [UIColor appSecondaryColor1];
    self.titleLabel.font = [UIFont appLightFontWithSize:26.f];
    
    self.videoMessageLabel.textColor = [UIColor appSecondaryColor1];
    self.videoMessageLabel.font = [UIFont appRegularFontWithSize:22.f];
    
    [self.videoButton setImage:[UIImage imageNamed:@"video_icon"] forState:UIControlStateNormal];

}

- (IBAction)watchVideo:(id) __unused sender
{
    if ([self.delegate respondsToSelector:@selector(studyVideoCollectionViewCellWatchVideo:)]) {
        [self.delegate studyVideoCollectionViewCellWatchVideo:self];
    }
}

@end
