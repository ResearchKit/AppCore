// 
//  APCStudyDetailsViewController.h 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import <UIKit/UIKit.h>
#import "APCTableViewItem.h"

@interface APCStudyDetailsViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (nonatomic, strong) APCTableViewStudyDetailsItem *studyDetails;

@end
