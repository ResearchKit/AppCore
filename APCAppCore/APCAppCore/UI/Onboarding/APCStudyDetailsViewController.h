// 
//  APCStudyDetailsViewController.h 
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
//
 
#import <UIKit/UIKit.h>
#import "APCTableViewItem.h"

@interface APCStudyDetailsViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (nonatomic, strong) APCTableViewStudyDetailsItem *studyDetails;

@end
