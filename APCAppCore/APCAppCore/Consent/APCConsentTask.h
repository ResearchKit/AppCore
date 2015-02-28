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

- (instancetype)initWithIdentifier:(NSString*)identifier propertiesFileName:(NSString*)fileName;

@end
