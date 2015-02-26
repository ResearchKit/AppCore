//
//  APCConsentInstructionQuestion.h
//  APCAppCore
//
//  Created by Edward Cessna on 2/22/15.
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <APCAppCore/APCAppCore.h>

@interface APCConsentInstructionQuestion : APCConsentQuestion

- (instancetype)initWithIdentifier:(NSString*)identifier
                            prompt:(NSString*)prompt
                              text:(NSString*)text;

- (BOOL)evaluate:(ORKStepResult*)stepResult;

- (ORKQuestionStep*)instantiateRkQuestion;

@end
