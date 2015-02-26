//
//  APCConsentBooleanQuestion.h
//  APCAppCore
//
//  Created by Edward Cessna on 2/22/15.
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCConsentQuestion.h"

@interface APCConsentBooleanQuestion : APCConsentQuestion

@property (nonatomic, assign) BOOL  expectedAnswer;

- (instancetype)initWithIdentifier:(NSString*)identifier
                            prompt:(NSString*)prompt
                    expectedAnswer:(BOOL)expectedAnswer;

@end
