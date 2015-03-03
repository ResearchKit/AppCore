//
//  APCConsentRedirector.h
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, APCConsentRedirection)
{
    APCConsentRedirectionNone,
    APCConsentBackToConsentBeginning,
    APCConsentBackToQuizBeginning,
    APCConsentBackToCustomStepBeginning
};


@protocol APCConsentRedirector <NSObject>

- (APCConsentRedirection)redirect;

@end
