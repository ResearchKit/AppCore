//
//  APCContainerStepViewController.h
//  APCAppCore
//
//  Created by Shannon Young on 2/23/16.
//  Copyright © 2016 Apple, Inc. All rights reserved.
//

#import <ResearchKit/ResearchKit.h>

@interface APCContainerStepViewController : ORKStepViewController

@property (nonatomic, readonly) UIViewController *childViewController;
@property (nonatomic, copy) NSArray <ORKResult*> *childResults;

- (instancetype)initWithStep:(ORKStep *)step childViewController:(UIViewController*)childViewController;

@end
