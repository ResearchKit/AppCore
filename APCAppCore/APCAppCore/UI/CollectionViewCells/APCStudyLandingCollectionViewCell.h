//
//  APCStudyLandingCollectionViewCell.h
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

FOUNDATION_EXPORT NSString *const kAPCStudyLandingCollectionViewCellIdentifier;

@protocol APCStudyLandingCollectionViewCellDelegate;

@interface APCStudyLandingCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *swipeLabel;

@property (weak, nonatomic) IBOutlet UIButton *readConsentButton;
@property (weak, nonatomic) IBOutlet UIButton *emailConsentButton;

@property (weak, nonatomic) id <APCStudyLandingCollectionViewCellDelegate> delegate;

- (IBAction)readConsent:(id)sender;
- (IBAction)emailConsent:(id)sender;

@end

@protocol APCStudyLandingCollectionViewCellDelegate <NSObject>

- (void)studyLandingCollectionViewCellReadConsent:(APCStudyLandingCollectionViewCell *)cell;

- (void)studyLandingCollectionViewCellEmailConsent:(APCStudyLandingCollectionViewCell *)cell;

@end
