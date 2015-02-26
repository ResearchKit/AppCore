// 
//  APCBaseTaskViewController.h 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import <Foundation/Foundation.h>
#import <ResearchKit/ResearchKit.h>
#import "APCScheduledTask.h"

@interface APCBaseTaskViewController : ORKTaskViewController <ORKTaskViewControllerDelegate, ORKStepViewControllerDelegate>
@property  (nonatomic, strong)  APCScheduledTask  *scheduledTask;
@property (nonatomic, copy) void (^createResultSummaryBlock) (NSManagedObjectContext* context);

+ (instancetype)customTaskViewController: (APCScheduledTask*) scheduledTask;
- (NSString *) createResultSummary;
- (void) storeInCoreDataWithFileName: (NSString *) fileName resultSummary: (NSString *) resultSummary;

@end
