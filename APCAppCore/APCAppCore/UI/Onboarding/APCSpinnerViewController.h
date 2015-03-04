// 
//  APCSpinnerViewController.h 
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
//
 
@import UIKit;

@interface APCSpinnerViewController : UIViewController

@property (nonatomic, weak) IBOutlet UIView *activityIndicatorContainerView;

@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicatorView;

@property (nonatomic) BOOL landscape;

@end
