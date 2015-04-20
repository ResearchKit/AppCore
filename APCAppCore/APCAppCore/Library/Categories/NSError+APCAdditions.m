// 
//  NSError+APCAdditions.m 
//  APCAppCore 
// 
// Copyright (c) 2015, Apple Inc. All rights reserved. 
// 
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
// 
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
// 
// 2.  Redistributions in binary form must reproduce the above copyright notice, 
// this list of conditions and the following disclaimer in the documentation and/or 
// other materials provided with the distribution. 
// 
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors 
// may be used to endorse or promote products derived from this software without 
// specific prior written permission. No license is granted to the trademarks of 
// the copyright holders even if such marks are included in this software. 
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE 
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
// 
 
#import "APCAppCore.h"

static NSString*    kServerTooDamnBusy              = @"Thank you for your interest in this study. We are working hard to process the large volume of interest, and should be back up momentarily. Please try again soon.";
static NSString*    kUnexpectConditionMessage       = @"An unexpected network condition has occurred. Please try again soon.";
static NSString*    kNotConnectedMessage            = @"You are currently not connected to the Internet. Please try again when you are connected to a network.";
static NSString*    kServerMaintanenceMessage       = @"The study server is currently undergoing maintanence. Please try again soon.";
static NSString*    kAccountAlreadyExists           = @"An account has already been created for this email address. Please use a different email address, or sign in using the \"already participating\" link at the bottom of the Welcome page.";
static NSString*    kAccountDoesNotExists           = @"There is no account registered for this email address.";
static NSString*    kBadEmailAddress                = @"The email address submitted is not a valid email address. Please correct the email address and try again.";
static NSString*    kBadPasswordAddress             = @"The password you have entered is not a valid password.  Please try again.";
static NSString*    kNotReachableMessage            = @"We are currently not able to reach the study server. Please retry in a few moments.";
static NSString*    kInvalidEmailAddressOrPassword  = @"Entered email address or password is not valid. Please correct the email address or password and try again.";
static NSString*    kSageMessageKey                 = @"message";
static NSString*    kSageErrorsKey                  = @"errors";
static NSString*    kSageErrorPasswordKey           = @"password";
static NSString*    kSageErrorEmailKey              = @"email";
static NSString*    kSageInvalidUsernameOrPassword  = @"Invalid username or password.";

static NSString * const oneTab = @"    ";


@implementation NSError (APCAdditions)

- (NSString*)checkMessageForNonUserTerms:(NSString*)message
{
    if ([message containsString:@"NSError"] ||
        [message containsString:@"NSURLError"] ||
        [message rangeOfString:@"contact somebody" options:NSCaseInsensitiveSearch].location != NSNotFound)
    {
        return NSLocalizedString(@"An unknown error occurred", nil);
    }
    else
    {
        return message;
    }
    
    return message;
}



// ---------------------------------------------------------
#pragma mark - Error handlers
// ---------------------------------------------------------

- (void)handle
{
    APCLogError(@"%@",self.localizedDescription?:self);
}


- (NSString*)bridgeErrorMessage
{
    NSString*   message;
    id          code = self.userInfo[SBB_ORIGINAL_ERROR_KEY];
    
    if ([code isKindOfClass:[NSError class]])
    {
        NSError*    e = (NSError*)code;
        
        if (e.code == kCFURLErrorNotConnectedToInternet)
        {
            message = NSLocalizedString(kNotConnectedMessage, nil);
        }
        else
        {
            APCLogError(@"Network error: %@", code);
        }
    }
    else if (self.code == 400)
    {
        // There are several messages that need to be displayed within the 400
        // Extract the internal message then act appropriately.
        NSDictionary * errors = [code valueForKey: kSageErrorsKey];
        if([errors valueForKey: kSageErrorEmailKey])
        {
            message = NSLocalizedString(kBadEmailAddress, nil);
        }
        else if([errors valueForKey: kSageErrorPasswordKey])
        {
            message = NSLocalizedString(kBadPasswordAddress, nil);
        } else
        {
            message = NSLocalizedString(kInvalidEmailAddressOrPassword, nil);
        }
        
    }
    else if (self.code == 409)
    {
        message = NSLocalizedString(kAccountAlreadyExists, nil);
    }
    else if (self.code == 404)
    {
        message = NSLocalizedString(kAccountDoesNotExists, nil);
    }
    else if ([code isEqual:@(503)] || self.code == 503)
    {
        message = NSLocalizedString(kServerTooDamnBusy, nil);
    }
    else if ([code  isEqual: @(kSBBInternetNotConnected)])
    {
        message = NSLocalizedString(kNotConnectedMessage, nil);
    }
    else if ([code isEqual:@(kSBBServerNotReachable)])
    {
        message = NSLocalizedString(kNotReachableMessage, nil);
    }
    else if ([code isEqual:@(kSBBServerUnderMaintenance)])
    {
        message = NSLocalizedString(kServerMaintanenceMessage, nil);
    }
    else
    {
        message = NSLocalizedString(kUnexpectConditionMessage, nil);
    }

    return message;
}


- (NSString*)networkErrorMessage
{
    NSString*   message;
    
    if (self.code == 409)
    {
        message = NSLocalizedString(kAccountAlreadyExists, nil);
    }
    else if (self.code == 404)
    {
        message = NSLocalizedString(kAccountDoesNotExists, nil);
    }
    else if (self.code >= 500 && self.code < 600)
    {
        message = NSLocalizedString(kServerTooDamnBusy, nil);
    }
    else if (self.code == kCFURLErrorDNSLookupFailed || self.code == kCFURLErrorInternationalRoamingOff)
    {
        message = NSLocalizedString(kNotConnectedMessage, nil);
    }
    else
    {
        message = NSLocalizedString(kUnexpectConditionMessage, nil);
    }
    
    return message;
}


- (NSString*)message
{
    NSString*   message = kUnexpectConditionMessage;
    
    if ([self.domain isEqualToString:(__bridge  NSString*)kCFErrorDomainCFNetwork])
    {
        message = [self networkErrorMessage];
    }
    else if ([self.domain isEqualToString:SBB_ERROR_DOMAIN])
    {
        message = [self bridgeErrorMessage];
    }
    
    return [NSString stringWithFormat:@"\n%@\n\nError code: %@", [self checkMessageForNonUserTerms:message], @(self.code)];
}



// ---------------------------------------------------------
#pragma mark - Convenience Initializers
// ---------------------------------------------------------

+ (NSError *) errorWithCode: (NSInteger)  code
                     domain: (NSString *) domain
              failureReason: (NSString *) localizedFailureReason
         recoverySuggestion: (NSString *) localizedRecoverySuggestion
{
    return [self errorWithCode: code
                        domain: domain
                 failureReason: localizedFailureReason
            recoverySuggestion: localizedRecoverySuggestion
               relatedFilePath: nil
                    relatedURL: nil
                   nestedError: nil
                 otherUserInfo: nil];
}

+ (NSError *) errorWithCode: (NSInteger)  code
                     domain: (NSString *) domain
              failureReason: (NSString *) localizedFailureReason
         recoverySuggestion: (NSString *) localizedRecoverySuggestion
                nestedError: (NSError *)  rootCause
{
    return [self errorWithCode: code
                        domain: domain
                 failureReason: localizedFailureReason
            recoverySuggestion: localizedRecoverySuggestion
               relatedFilePath: nil
                    relatedURL: nil
                   nestedError: rootCause
                 otherUserInfo: nil];
}

+ (NSError *) errorWithCode: (NSInteger)  code
                     domain: (NSString *) domain
              failureReason: (NSString *) localizedFailureReason
         recoverySuggestion: (NSString *) localizedRecoverySuggestion
            relatedFilePath: (NSString *) someFilePath
{
    return [self errorWithCode: code
                        domain: domain
                 failureReason: localizedFailureReason
            recoverySuggestion: localizedRecoverySuggestion
               relatedFilePath: someFilePath
                    relatedURL: nil
                   nestedError: nil
                 otherUserInfo: nil];
}

+ (NSError *) errorWithCode: (NSInteger)  code
                     domain: (NSString *) domain
              failureReason: (NSString *) localizedFailureReason
         recoverySuggestion: (NSString *) localizedRecoverySuggestion
                 relatedURL: (NSURL *)    someURL
{
    return [self errorWithCode: code
                        domain: domain
                 failureReason: localizedFailureReason
            recoverySuggestion: localizedRecoverySuggestion
               relatedFilePath: nil
                    relatedURL: someURL
                   nestedError: nil
                 otherUserInfo: nil];
}

+ (NSError *) errorWithCode: (NSInteger)  code
                     domain: (NSString *) domain
              failureReason: (NSString *) localizedFailureReason
         recoverySuggestion: (NSString *) localizedRecoverySuggestion
            relatedFilePath: (NSString *) someFilePath
                 relatedURL: (NSURL *)    someURL
                nestedError: (NSError *)  rootCause
{
    return [self errorWithCode: code
                        domain: domain
                 failureReason: localizedFailureReason
            recoverySuggestion: localizedRecoverySuggestion
               relatedFilePath: someFilePath
                    relatedURL: someURL
                   nestedError: rootCause
                 otherUserInfo: nil];
}

+ (NSError *) errorWithCode: (NSInteger)  code
                     domain: (NSString *) domain
              failureReason: (NSString *) localizedFailureReason
         recoverySuggestion: (NSString *) localizedRecoverySuggestion
            relatedFilePath: (NSString *) someFilePath
                 relatedURL: (NSURL *)    someURL
                nestedError: (NSError *)  rootCause
              otherUserInfo: (NSDictionary *) otherUserInfo
{
    NSMutableDictionary *userInfo = [NSMutableDictionary new];

    [userInfo addEntriesFromDictionary: otherUserInfo];

    if (localizedFailureReason)         {  [userInfo  setValue: localizedFailureReason       forKey: NSLocalizedFailureReasonErrorKey       ];  }
    if (localizedRecoverySuggestion)    {  [userInfo  setValue: localizedRecoverySuggestion  forKey: NSLocalizedRecoverySuggestionErrorKey  ];  }
    if (someFilePath)                   {  [userInfo  setValue: someFilePath                 forKey: NSFilePathErrorKey                     ];  }
    if (someURL)                        {  [userInfo  setValue: someURL                      forKey: NSURLErrorKey                          ];  }
    if (rootCause)                      {  [userInfo  setValue: rootCause                    forKey: NSUnderlyingErrorKey                   ];  }

    NSError *error = [NSError errorWithDomain: domain
                                         code: code
                                     userInfo: userInfo];

    return error;
}



// ---------------------------------------------------------
#pragma mark - Friendly printouts
// ---------------------------------------------------------

- (NSString *) friendlyFormattedString
{
    return [self friendlyFormattedStringAtLevel: 0];
}

- (NSString *) friendlyFormattedStringAtLevel: (NSUInteger) tabLevel
{
    NSMutableString *output = [NSMutableString new];

    NSString *tab = [@"" stringByPaddingToLength: tabLevel * oneTab.length
                                      withString: oneTab
                                 startingAtIndex: 0];

    NSString *tabForNestedObjects = [NSString stringWithFormat: @"\n%@", tab];

    NSString *domain = self.domain.length > 0 ? self.domain : @"(none)";

    [output appendFormat: @"%@Code: %@\n", tab, @(self.code)];
    [output appendFormat: @"%@Domain: %@\n", tab, domain];

    if (self.userInfo.count > 0)
    {
        for (NSString *key in [self.userInfo.allKeys sortedArrayUsingSelector: @selector (compare:)])
        {
            id value = self.userInfo [key];
            NSString *valueString = nil;

            if ([value isKindOfClass: [NSError class]])
            {
                valueString = [value friendlyFormattedStringAtLevel: tabLevel + 1];
                [output appendFormat: @"%@%@:\n%@", tab, key, valueString];
            }

            else
            {
                valueString = [NSString stringWithFormat: @"%@", value];
                valueString = [valueString stringByReplacingOccurrencesOfString: @"\\n" withString: @"\n"];
                valueString = [valueString stringByReplacingOccurrencesOfString: @"\\\"" withString: @"\""];
                valueString = [valueString stringByReplacingOccurrencesOfString: @"\n" withString: tabForNestedObjects];
                [output appendFormat: @"%@%@: %@\n", tab, key, valueString];
            }
        }
    }

    if (tabLevel == 0)
    {
        [output insertString: @"An error occurred. Available info:\n----- ERROR INFO -----\n" atIndex: 0];

        if ([output characterAtIndex: output.length - 1] != '\n')
        {
            [output appendString: @"\n"];
        }

        [output appendString: @"----------------------"];
    }

    /*
     Ship it.
     */
    return output;
}

@end











