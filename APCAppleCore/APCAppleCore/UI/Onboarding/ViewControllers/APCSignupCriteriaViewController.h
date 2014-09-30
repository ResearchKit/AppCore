//
//  APCSignupCriteriaViewController.h
//  APCAppleCore
//
//  Created by Karthik Keyan on 9/3/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCSignupViewController.h"

@interface APCSignupCriteriaViewController : APCViewController <UITableViewDataSource, UITableViewDelegate, APCConfigurableCellDelegate, RKConsentViewControllerDelegate>

- (void)startSignUp;

@end
