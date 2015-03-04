// 
//  APCStudyOverviewViewController.h 
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//
 
#import <UIKit/UIKit.h>
#import "APCTableViewItem.h"
#import "APCTintedTableViewCell.h"
#import "APCStudyOverviewCollectionViewCell.h"
#import "APCStudyVideoCollectionViewCell.h"
#import "APCStudyLandingCollectionViewCell.h"

@import MessageUI;

@interface APCStudyOverviewCollectionViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate, MFMailComposeViewControllerDelegate, APCStudyVideoCollectionViewCellDelegate, APCStudyLandingCollectionViewCellDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UILabel *diseaseNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateRangeLabel;
@property (weak, nonatomic) IBOutlet UIButton *joinButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIImageView *researchInstituteImageView;

@property (strong, nonatomic) NSString *diseaseName;

@property (nonatomic, strong) NSArray *items;

@property (nonatomic) BOOL showShareRow;

@property (nonatomic) BOOL showConsentRow;

- (IBAction)signInTapped:(id)sender;
- (IBAction)signUpTapped:(id)sender;

- (NSArray *)prepareContent;
- (NSArray *)studyDetailsFromJSONFile:(NSString *)jsonFileName;

- (APCTableViewStudyDetailsItem *)itemForIndexPath:(NSIndexPath *)indexPath;
- (APCTableViewStudyItemType)itemTypeForIndexPath:(NSIndexPath *)indexPath;

@end
