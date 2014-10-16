//
//  APCInclusionCriteriaViewController.h
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 10/14/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface APCInclusionCriteriaViewController : UITableViewController

//Abstract Implementations
- (void) next;
- (BOOL) isContentValid;

@end
