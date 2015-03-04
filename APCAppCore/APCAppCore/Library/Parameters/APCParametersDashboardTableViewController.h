// 
//  APCParametersDashboardTableViewController.h 
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//
 
#import <UIKit/UIKit.h>
#import "APCParameters.h"
#import "APCParametersCell.h"
#import "APCParametersCoreDataCell.h"
#import "APCParametersUserDefaultCell.h"
#import "APCParameters.h"

@interface APCParametersDashboardTableViewController : UITableViewController <APCParametersCellDelegate, APCParametersDelegate, APCParametersCoreDataCellDelegate, UITextFieldDelegate>
@property (strong, nonatomic) APCParameters *parameters;

@property (strong, nonatomic) NSMutableArray *coreDataParameters;
@property (strong, nonatomic) NSMutableArray *userDefaultParameters;
@end
