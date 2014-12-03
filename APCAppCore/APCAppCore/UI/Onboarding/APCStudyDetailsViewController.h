//
//  APCStudyDetailsViewController.h
//  APCAppCore
//
//  Created by Ramsundar Shandilya on 10/28/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APCTableViewItem.h"

@interface APCStudyDetailsViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (nonatomic, strong) APCTableViewStudyDetailsItem *studyDetails;

@end
