// 
//  NSError+APCAdditions.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "APCAppCore.h"

@implementation NSError (APCAdditions)

+ (NSDictionary *)errorMapCFNetwork {
    static NSDictionary* dictionary = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        NSString *clientNetworkIssue = NSLocalizedString(@"Client encountered a network issue", @"Client encountered a network issue");
        NSString *serverNetworkIssue = NSLocalizedString(@"Server encountered a network issue", @"Server encountered a network issue");
        NSString *resourceUnavailable = NSLocalizedString(@"Resource unavailable", @"Resource unavailable");
        NSString *noNetwork = NSLocalizedString(@"No network available", @"No network available");
        NSString *noResource = NSLocalizedString(@"No resource available", @"No resource available");
        NSString *networkConnectionLost = NSLocalizedString(@"Network connection lost", @"Network connection lost");
        NSString *notConnected = NSLocalizedString(@"Not connected to the internet", @"Not connected to the internet");
        NSString *serverBusy = NSLocalizedString(@"Server is busy", @"Server is busy");
        NSString *authenticationRequired = NSLocalizedString(@"Authentication required", @"Authentication required");
                        //Client network issue
        dictionary = @{[NSNumber numberWithInteger:kCFURLErrorUnknown] : clientNetworkIssue,
                       [NSNumber numberWithInteger:kCFURLErrorCancelled] : clientNetworkIssue,
                       [NSNumber numberWithInteger:kCFURLErrorUserCancelledAuthentication] : clientNetworkIssue,
                       [NSNumber numberWithInteger:kCFURLErrorDataNotAllowed] : clientNetworkIssue,
                       [NSNumber numberWithInteger:kCFURLErrorRequestBodyStreamExhausted] : clientNetworkIssue,
                       
                       //Server network issue
                       [NSNumber numberWithInteger:kCFURLErrorBadURL] : serverNetworkIssue,
                       [NSNumber numberWithInteger:kCFURLErrorTimedOut] : serverNetworkIssue,
                       [NSNumber numberWithInteger:kCFURLErrorUnsupportedURL] : serverNetworkIssue,
                       [NSNumber numberWithInteger:kCFURLErrorCannotFindHost] : serverNetworkIssue,
                       [NSNumber numberWithInteger:kCFURLErrorCannotConnectToHost] : serverNetworkIssue,
                       [NSNumber numberWithInteger:kCFURLErrorHTTPTooManyRedirects] : serverNetworkIssue,
                       [NSNumber numberWithInteger:kCFURLErrorBadServerResponse] : serverNetworkIssue,
                       
                       //Resource unavailable
                       [NSNumber numberWithInteger:kCFURLErrorResourceUnavailable] : resourceUnavailable,
                       [NSNumber numberWithInteger:kCFURLErrorCannotDecodeRawData] : resourceUnavailable,
                       [NSNumber numberWithInteger:kCFURLErrorCannotDecodeContentData] : resourceUnavailable,
                       [NSNumber numberWithInteger:kCFURLErrorCannotParseResponse] : resourceUnavailable,
                       [NSNumber numberWithInteger:kCFURLErrorFileIsDirectory] : resourceUnavailable,
                       [NSNumber numberWithInteger:kCFURLErrorNoPermissionsToReadFile] : resourceUnavailable,
                       [NSNumber numberWithInteger:kCFURLErrorDataLengthExceedsMaximum] : resourceUnavailable,
                       
                       //No resource
                       [NSNumber numberWithInteger:kCFURLErrorRedirectToNonExistentLocation] : noResource,
                       [NSNumber numberWithInteger:kCFURLErrorZeroByteResource] : noResource,
                       [NSNumber numberWithInteger:kCFURLErrorFileDoesNotExist] : noResource,
                       
                       //No network
                       [NSNumber numberWithInteger:kCFURLErrorDNSLookupFailed] : noNetwork,
                       [NSNumber numberWithInteger:kCFURLErrorInternationalRoamingOff] : noNetwork,
                       
                       //Network connection lost
                       [NSNumber numberWithInteger:kCFURLErrorNetworkConnectionLost] : networkConnectionLost,
                       
                       //Not connected
                       [NSNumber numberWithInteger:kCFURLErrorNotConnectedToInternet] : notConnected,
                       
                       //Server is busy
                       [NSNumber numberWithInteger:kCFURLErrorCallIsActive] : serverBusy,
                       
                       
                       //Not authenticated
                       [NSNumber numberWithInteger:kCFURLErrorUserAuthenticationRequired] : authenticationRequired
                       };
    });
    return dictionary;
}

/*********************************************************************************/
#pragma mark - Error handlers
/*********************************************************************************/

- (void) handle
{
    APCLogError(@"%@",self.localizedDescription?:self);
}

- (NSString *) message {
    
    NSString *message;
    
    if ([self.domain isEqualToString:(__bridge  NSString *)kCFErrorDomainCFNetwork]) {
        NSString *mappedMessage;
        message = (mappedMessage = [[NSError errorMapCFNetwork] objectForKey:[NSNumber numberWithInteger:self.code]]) ? mappedMessage : NSLocalizedString(@"An unhandled error occurred", @"An unhandled error occurred");
    } else {
        id localError = self.userInfo[SBB_ORIGINAL_ERROR_KEY];
        
        if (self.code < kSBBUnknownError) {
            message = self.localizedDescription;
        }
        else {
            if ([localError isKindOfClass:[NSError class]]) {
                message = [(NSError *)localError localizedDescription];
            }
            else {
                message = [localError objectForKey:@"message"];
            }
        }
    }
    
    return message;
}


@end
