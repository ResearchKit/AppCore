//
//  APCStudyLandingCollectionViewCell.m
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
//

#import "APCStudyLandingCollectionViewCell.h"
#import "UIColor+APCAppearance.h"
#import "UIFont+APCAppearance.h"

NSString *const kAPCStudyLandingCollectionViewCellIdentifier = @"APCStudyLandingCollectionViewCell";

@implementation APCStudyLandingCollectionViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setupAppearance];
}

- (void)setupAppearance
{
    self.logoImageView.image = [UIImage imageNamed:@"logo_disease_large"];
    
    self.titleLabel.textColor = [UIColor appSecondaryColor1];
    self.titleLabel.font = [UIFont appLightFontWithSize:36.f];
    [self.titleLabel setAdjustsFontSizeToFitWidth:YES];
    self.titleLabel.minimumScaleFactor = 0.8;
    
    self.subTitleLabel.textColor = [UIColor appSecondaryColor1];
    self.subTitleLabel.font = [UIFont appMediumFontWithSize:17.f];
    
    self.swipeLabel.textColor = [UIColor appSecondaryColor3];
    self.swipeLabel.font = [UIFont appMediumFontWithSize:15.f];
    
    [self.emailConsentButton setTitle:NSLocalizedString(@"Email Consent Document", @"Email Consent Document") forState:UIControlStateNormal];
    [self.emailConsentButton setTitleColor:[UIColor appPrimaryColor] forState:UIControlStateNormal];
    
    [self.readConsentButton setTitle:NSLocalizedString(@"Read Consent Document", @"Read Consent Document") forState:UIControlStateNormal];
    [self.readConsentButton setTitleColor:[UIColor appPrimaryColor] forState:UIControlStateNormal];

}


- (IBAction)readConsent:(id) __unused sender
{
    if ([self.delegate respondsToSelector:@selector(studyLandingCollectionViewCellReadConsent:)]) {
        [self.delegate studyLandingCollectionViewCellReadConsent:self];
    }
}

- (IBAction)emailConsent:(id) __unused sender
{
    if ([self.delegate respondsToSelector:@selector(studyLandingCollectionViewCellEmailConsent:)]) {
        [self.delegate studyLandingCollectionViewCellEmailConsent:self];
    }
}

@end
