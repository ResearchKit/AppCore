// 
//  NSError+APCAdditions.m 
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//
 
#import "APCAppCore.h"

static NSString*    kServerTooDamnBusy          = @"Thank you for your interest in this study. We are working hard to process the large volume of interest, and should be back up momentarily.";
static NSString*    kUnexpectConditionMessage   = @"An unexpected condition has been encountered. Please retry in a few moments.";
static NSString*    kNotConnectedMessage        = @"You are currently not connected to the Internet.";
static NSString*    kServerMaintanenceMessage   = @"The study server is currently undergoing maintanence. Please retry in a few moments.";
static NSString*    kAccountAlreadyExists       = @"This account already exists.";

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

/*********************************************************************************/
#pragma mark - Error handlers
/*********************************************************************************/

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
        message = [(NSError*)code localizedDescription];
    }
    else
    {
        if (self.code == 409)
        {
            message = NSLocalizedString(kAccountAlreadyExists, nil);
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
            message = NSLocalizedString(@"You are currently not able to reach the study server. Please retry in a few moments.", nil);
        }
        else if ([code isEqual:@(kSBBServerUnderMaintenance)])
        {
            message = NSLocalizedString(@"The study server currently under maintenance", nil);
        }
        else
        {
            message = NSLocalizedString(kUnexpectConditionMessage, nil);
        }
    }

    return message;
}


- (NSString*)networkErrorMessage
{
    NSString*   message;
    
    if (self.code >= 500 && self.code < 600)
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
    
    return [NSString stringWithFormat:@"%@ (%@)", [self checkMessageForNonUserTerms:message], @(self.code)];
}


@end
