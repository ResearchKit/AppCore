// 
//  APCInclusionCriteriaViewController.h 
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//
 
#import <UIKit/UIKit.h>

@interface APCInclusionCriteriaViewController : UITableViewController

//Abstract Implementations
- (void) next;
- (BOOL) isContentValid;

@end
