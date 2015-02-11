//
//  APCStudyOverviewCollectionViewCell.h
//  APCAppCore
//
//  Created by Dzianis Asanovich on 2/10/15.
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface APCStudyOverviewCollectionViewCell : UICollectionViewCell <UIWebViewDelegate>

@property(nonatomic, weak) IBOutlet UIWebView * webView;

@end
