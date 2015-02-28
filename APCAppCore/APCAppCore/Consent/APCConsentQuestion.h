//
//  APCConsentQuestion.h
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ResearchKit/ResearchKit.h>

@interface APCConsentQuestion : NSObject

@property (nonatomic, copy) NSString* identifier;
@property (nonatomic, copy) NSString* prompt;

- (instancetype)initWithIdentifier:(NSString*)identifier prompt:(NSString*)prompt;
- (BOOL)evaluate:(ORKStepResult*)stepResult;

- (ORKStep*)instantiateRkQuestion;

@end
