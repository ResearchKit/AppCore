//
//  APCStudyOverviewVideoCollectionViewCell.h
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APCButton.h"

FOUNDATION_EXPORT NSString *const kAPCStudyVideoCollectionViewCellIdentifier;

@protocol APCStudyVideoCollectionViewCellDelegate;

@interface APCStudyVideoCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *videoMessageLabel;
@property (weak, nonatomic) IBOutlet UIButton *videoButton;
@property (weak, nonatomic) IBOutlet UILabel *consentMessageLabel;
@property (weak, nonatomic) IBOutlet UIButton *consentButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewheightConstraint;
@property (weak, nonatomic) IBOutlet APCButton *emailConsentButton;

@property (weak, nonatomic) id <APCStudyVideoCollectionViewCellDelegate> delegate;

- (IBAction)watchVideo:(id)sender;
- (IBAction)readConsent:(id)sender;
- (IBAction)emailConsent:(id)sender;


@end

@protocol APCStudyVideoCollectionViewCellDelegate <NSObject>

- (void)studyVideoCollectionViewCellWatchVideo:(APCStudyVideoCollectionViewCell *)cell;

- (void)studyVideoCollectionViewCellReadConsent:(APCStudyVideoCollectionViewCell *)cell;

- (void)studyVideoCollectionViewCellEmailConsent:(APCStudyVideoCollectionViewCell *)cell;

@end
