// 
//  APCBaseWithProgressTaskViewController.h 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 

#import <UIKit/UIKit.h>
#import "APCBaseTaskViewController.h"

@interface APCBaseWithProgressTaskViewController : APCBaseTaskViewController

@property (nonatomic, strong) NSArray * stepsToAutomaticallyAdvanceOnTimer; //Provide step identifiers. Would work only with ORKActiveStepViewController

@end
