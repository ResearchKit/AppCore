//
//  APCConsentInstructionQuestion.m
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCConsentInstructionQuestion.h"

@interface APCConsentInstructionQuestion ()

@property (nonatomic, copy) NSString*   text;

@end

@implementation APCConsentInstructionQuestion

- (instancetype)initWithIdentifier:(NSString*)identifier
                            prompt:(NSString*)prompt
                              text:(NSString*)text
{
    self = [super initWithIdentifier:identifier prompt:prompt];
    if (self)
    {
        _text = text;
    }
    
    return self;
}

- (BOOL)evaluate:(ORKStepResult*) __unused stepResult
{
    return YES;
}

- (ORKStep*)instantiateRkQuestion
{
    ORKInstructionStep* step = [[ORKInstructionStep alloc] initWithIdentifier:self.identifier];
    
    step.title = self.prompt;
    step.text  = self.text;
    
    return step;
}

@end
