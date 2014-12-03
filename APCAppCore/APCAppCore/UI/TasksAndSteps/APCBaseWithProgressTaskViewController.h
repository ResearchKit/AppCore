//
//  APCBaseWithProgressTaskViewController.h
//  APCAppCore
//
//  Created by Dhanush Balachandran on 11/10/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "APCBaseTaskViewController.h"

@interface APCBaseWithProgressTaskViewController : APCBaseTaskViewController

@property (nonatomic, strong) NSArray * stepsToAutomaticallyAdvanceOnTimer; //Provide step identifiers. Would work only with RKSTActiveStepViewController

@end
