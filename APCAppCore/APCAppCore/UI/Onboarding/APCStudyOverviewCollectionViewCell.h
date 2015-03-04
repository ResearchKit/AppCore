//
//  APCStudyOverviewCollectionViewCell.h
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

FOUNDATION_EXPORT NSString *const kAPCStudyOverviewCollectionViewCellIdentifier;

@interface APCStudyOverviewCollectionViewCell : UICollectionViewCell <UIWebViewDelegate>

@property(nonatomic, weak) IBOutlet UIWebView * webView;

@end
