//
//  APCConsentTask.h
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ResearchKit/ResearchKit.h>
#import "APCConsentQuestion.h"


@interface APCConsentTask : ORKOrderedTask <ORKTask>

@property (nonatomic, strong) ORKConsentDocument*   consentDocument;

- (instancetype)initWithIdentifier:(NSString*)identifier propertiesFileName:(NSString*)fileName;
- (instancetype)initWithIdentifier:(NSString*)identifier propertiesFileName:(NSString*)fileName customSteps:(NSArray*)customSteps;

@end
