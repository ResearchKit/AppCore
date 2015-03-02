//
//  APCConsentTask.h
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ResearchKit/ResearchKit.h>
#import "APCConsentQuestion.h"
#import "APCConsentRedirector.h"


@interface APCConsentTask : ORKOrderedTask <ORKTask>

@property (nonatomic, strong) ORKConsentDocument*       consentDocument;
@property (nonatomic, strong) id<APCConsentRedirector>  redirector;
@property (nonatomic, strong) NSString*                 failedMessageTag;


- (instancetype)initWithIdentifier:(NSString*)identifier propertiesFileName:(NSString*)fileName;
- (instancetype)initWithIdentifier:(NSString*)identifier propertiesFileName:(NSString*)fileName customSteps:(NSArray*)customSteps;

@end
