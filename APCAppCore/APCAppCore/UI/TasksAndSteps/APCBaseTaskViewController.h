// 
//  APCBaseTaskViewController.h 
//  APCAppCore 
// 
// Copyright (c) 2015, Apple Inc. All rights reserved. 
// 
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
// 
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
// 
// 2.  Redistributions in binary form must reproduce the above copyright notice, 
// this list of conditions and the following disclaimer in the documentation and/or 
// other materials provided with the distribution. 
// 
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors 
// may be used to endorse or promote products derived from this software without 
// specific prior written permission. No license is granted to the trademarks of 
// the copyright holders even if such marks are included in this software. 
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE 
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
// 
 
#import <Foundation/Foundation.h>
#import <ResearchKit/ResearchKit.h>
#import "APCScheduledTask.h"
#import "APCTaskGroup.h"

@class APCAppDelegate;

@interface APCBaseTaskViewController : ORKTaskViewController <ORKTaskViewControllerDelegate, ORKStepViewControllerDelegate>

@property  (nonatomic, strong)  APCScheduledTask  *scheduledTask;
@property (nonatomic, copy) void (^createResultSummaryBlock) (NSManagedObjectContext* context);
@property (readonly) APCAppDelegate *appDelegate;
@property (nonatomic) BOOL canGenerateResult;

/**
 Older, default version of an initialization method.  Initializes
 your subclass of this ViewController with a ScheduledTask.  Compare
 with +configureTaskViewController:.
 */
+ (instancetype)customTaskViewController: (APCScheduledTask*) scheduledTask;

/**
 Initializes an instance of this class with the task
 represented by the taskGroup.  By default, creates
 a new ScheduledTask from the TaskGroup, and initializes
 your subclass with it.  Feel free to override this method
 if you want to interact directly with the higher-level
 data in the TaskGroup itself.
 */
+ (instancetype)configureTaskViewController:(APCTaskGroup *)taskGroup;

- (NSString *) createResultSummary;
- (void) storeInCoreDataWithFileName: (NSString *) fileName
                       resultSummary: (NSString *) resultSummary
                        usingContext: (NSManagedObjectContext *) context;

@end
