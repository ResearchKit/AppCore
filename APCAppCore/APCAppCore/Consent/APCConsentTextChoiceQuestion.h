//
//  APCConsentTextChoiceQuestion.h
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <APCAppCore/APCAppCore.h>

@interface APCConsentTextChoiceQuestion : APCConsentQuestion

@property (nonatomic, strong) NSArray*      answers;
@property (nonatomic, assign) NSUInteger    indexOfExpectedAnswer;

- (instancetype)initWithIdentifier:(NSString*)identifier
                            prompt:(NSString*)prompt
                           answers:(NSArray*)answers
                    expectedAnswer:(NSUInteger)indexOfExpectedAnswer;

@end
