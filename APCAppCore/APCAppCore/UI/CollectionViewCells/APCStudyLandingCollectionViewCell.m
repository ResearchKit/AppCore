// 
//  APCStudyLandingCollectionViewCell.m 
//  APCAppCore 
// 
// Copyright (c) 2015, Apple Inc. All rights reserved. 
// 
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
// 
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
// 
// 2.  Redistributions in binary form must reproduce the above copyright notice, 
// this list of conditions and the following disclaimer in the documentation and/or 
// other materials provided with the distribution. 
// 
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors 
// may be used to endorse or promote products derived from this software without 
// specific prior written permission. No license is granted to the trademarks of 
// the copyright holders even if such marks are included in this software. 
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE 
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
// 
 
#import "APCStudyLandingCollectionViewCell.h"
#import "UIColor+APCAppearance.h"
#import "UIFont+APCAppearance.h"
@import MessageUI;

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
