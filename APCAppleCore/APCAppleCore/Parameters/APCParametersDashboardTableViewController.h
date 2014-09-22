//
//  APCParametersDashboardTableViewController.h
//  APCAppleCore
//
//  Created by Justin Warmkessel on 9/19/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APCParameters.h"
#import "APCParametersCell.h"
#import "APCParameters.h"

@interface APCParametersDashboardTableViewController : UITableViewController <APCParametersCellDelegate, APCParametersDelegate>
@property (strong, nonatomic) APCParameters *parameters;

@end
