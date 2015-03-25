// 
//  NSError+APCAdditions.m 
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//
 
#import "APCAppCore.h"

static NSString*    kServerTooDamnBusy              = @"Thank you for your interest in this study. We are working hard to process the large volume of interest, and should be back up momentarily. Please try again soon.";
static NSString*    kUnexpectConditionMessage       = @"An unexpected condition has occurred. Please try again soon.";
static NSString*    kNotConnectedMessage            = @"You are currently not connected to the Internet. Please try again when you are connected to a network.";
static NSString*    kServerMaintanenceMessage       = @"The study server is currently undergoing maintanence. Please try again soon.";
static NSString*    kAccountAlreadyExists           = @"An account has already been created for this email address. Please use a different email address, or sign in using the \"already participating\" link at the bottom of the Welcome page.";
static NSString*    kAccountDoesNotExists           = @"There is no account registered for this email address.";
static NSString*    kBadEmailAddress                = @"The email address submitted is not a valid email address. Please correct the email address and try again.";
static NSString*    kNotReachableMessage            = @"We are currently not able to reach the study server. Please retry in a few moments.";
static NSString*    kInvalidEmailAddressOrPassword  = @"Entered email address or password is not valid. Please correct the email address or password and try again.";
static NSString*    kSageMessageKey                 = @"message";
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
        NSString * messageText =[code valueForKey:kSageMessageKey];
        
        if([messageText isEqualToString:(kSageInvalidUsernameOrPassword)])
        {
            message = NSLocalizedString(kInvalidEmailAddressOrPassword, nil);
        }
        else
        {
            message = NSLocalizedString(kBadEmailAddress, nil);
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
                   nestedError: nil];
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
                   nestedError: rootCause];
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
                   nestedError: nil];
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
                   nestedError: nil];
}

+ (NSError *) errorWithCode: (NSInteger)  code
                     domain: (NSString *) domain
              failureReason: (NSString *) localizedFailureReason
         recoverySuggestion: (NSString *) localizedRecoverySuggestion
            relatedFilePath: (NSString *) someFilePath
                 relatedURL: (NSURL *)    someURL
                nestedError: (NSError *)  rootCause
{
    NSMutableDictionary *userInfo = [NSMutableDictionary new];

    if (localizedFailureReason)         { userInfo [NSLocalizedFailureReasonErrorKey]       = localizedFailureReason;       }
    if (localizedRecoverySuggestion)    { userInfo [NSLocalizedRecoverySuggestionErrorKey]  = localizedRecoverySuggestion;  }
    if (someFilePath)                   { userInfo [NSFilePathErrorKey]                     = someFilePath;                 }
    if (someURL)                        { userInfo [NSURLErrorKey]                          = someURL;                      }
    if (rootCause)                      { userInfo [NSUnderlyingErrorKey]                   = rootCause;                    }

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

            if ([key isEqualToString: NSUnderlyingErrorKey] && [value isKindOfClass: [NSError class]])
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
        [output appendString: @"\n----------------------"];
    }

    /*
     Ship it.
     */
    return output;
}

@end











