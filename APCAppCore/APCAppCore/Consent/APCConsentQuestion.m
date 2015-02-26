//
//  APCConsentQuestion.m
//  APCAppCore
//
//  Created by Edward Cessna on 2/22/15.
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCConsentQuestion.h"

@implementation APCConsentQuestion

- (instancetype)initWithIdentifier:(NSString*)identifier prompt:(NSString*)prompt
{
    self = [super init];
    if (self)
    {
        _identifier = identifier;
        _prompt     = prompt;
    }
    
    return self;
}

- (BOOL)evaluate:(ORKStepResult*)stepResult
{
    return false;
}

- (ORKStep*)instantiateRkQuestion
{
    return nil;
}

@end
