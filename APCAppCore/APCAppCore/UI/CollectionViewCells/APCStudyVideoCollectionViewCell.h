//
//  APCStudyOverviewVideoCollectionViewCell.h
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APCButton.h"

FOUNDATION_EXPORT NSString *const kAPCStudyVideoCollectionViewCellIdentifier;

@protocol APCStudyVideoCollectionViewCellDelegate;

@interface APCStudyVideoCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *videoMessageLabel;
@property (weak, nonatomic) IBOutlet UIButton *videoButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewheightConstraint;

@property (weak, nonatomic) id <APCStudyVideoCollectionViewCellDelegate> delegate;

- (IBAction)watchVideo:(id)sender;

@end

@protocol APCStudyVideoCollectionViewCellDelegate <NSObject>

- (void)studyVideoCollectionViewCellWatchVideo:(APCStudyVideoCollectionViewCell *)cell;

- (void)studyVideoCollectionViewCellReadConsent:(APCStudyVideoCollectionViewCell *)cell;

- (void)studyVideoCollectionViewCellEmailConsent:(APCStudyVideoCollectionViewCell *)cell;

@end
