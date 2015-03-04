// 
//  APCBaseWithProgressTaskViewController.h 
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APCBaseTaskViewController.h"

@interface APCBaseWithProgressTaskViewController : APCBaseTaskViewController

@property (nonatomic, strong) NSArray * stepsToAutomaticallyAdvanceOnTimer; //Provide step identifiers. Would work only with ORKActiveStepViewController

@end
