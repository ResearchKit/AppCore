//
//  APCConsentBooleanQuestion.h
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCConsentQuestion.h"

@interface APCConsentBooleanQuestion : APCConsentQuestion

@property (nonatomic, assign) BOOL  expectedAnswer;

- (instancetype)initWithIdentifier:(NSString*)identifier
                            prompt:(NSString*)prompt
                    expectedAnswer:(BOOL)expectedAnswer;

@end
