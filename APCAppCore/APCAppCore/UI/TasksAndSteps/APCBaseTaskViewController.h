// 
//  APCBaseTaskViewController.h 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import <Foundation/Foundation.h>
#import <ResearchKit/ResearchKit.h>
#import "APCScheduledTask.h"

@interface APCBaseTaskViewController : RKSTTaskViewController <RKSTTaskViewControllerDelegate, RKSTStepViewControllerDelegate>
@property  (nonatomic, strong)  APCScheduledTask  *scheduledTask;

// For debugging.
@property (readonly) BOOL shouldEncryptArchiveFile;

+ (instancetype)customTaskViewController: (APCScheduledTask*) scheduledTask;
- (NSString *) createResultSummary;

@end
