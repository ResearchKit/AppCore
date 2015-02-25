//
//  APCStudyOverviewVideoCollectionViewCell.m
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
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
    self.titleLabel.font = [UIFont appMediumFontWithSize:26.f];
    
    self.videoMessageLabel.textColor = [UIColor appSecondaryColor1];
    self.videoMessageLabel.font = [UIFont appRegularFontWithSize:22.f];
    
    self.consentMessageLabel.textColor = [UIColor appSecondaryColor1];
    self.consentMessageLabel.font = [UIFont appLightFontWithSize:15.f];
    
    [self.videoButton setImage:[UIImage imageNamed:@"video_icon"] forState:UIControlStateNormal];
    
    [self.consentButton setImage:[UIImage imageNamed:@"read_consent_icon"] forState:UIControlStateNormal];
}

- (IBAction)watchVideo:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(studyVideoCollectionViewCellWatchVideo:)]) {
        [self.delegate studyVideoCollectionViewCellWatchVideo:self];
    }
}

- (IBAction)readConsent:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(studyVideoCollectionViewCellReadConsent:)]) {
        [self.delegate studyVideoCollectionViewCellReadConsent:self];
    }
}

- (IBAction)emailConsent:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(studyVideoCollectionViewCellEmailConsent:)]) {
        [self.delegate studyVideoCollectionViewCellEmailConsent:self];
    }
}

@end
