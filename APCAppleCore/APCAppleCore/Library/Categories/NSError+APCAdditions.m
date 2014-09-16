//
//  NSError+APCAdditions.m
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 8/22/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCAppleCore.h"

@implementation NSError (APCAdditions)

/*********************************************************************************/
#pragma mark - Error Generators
/*********************************************************************************/
+ (NSError *) generateAPCErrorForNSURLError:(NSError *)urlError isInternetConnected:(BOOL)internetConnected isServerReachable:(BOOL)isServerReachable
{
    NSError * retError;
    if (!internetConnected) {
        retError = [NSError errorWithDomain:APC_ERROR_DOMAIN code:kAPCInternetNotConnected userInfo:@{NSLocalizedDescriptionKey: @"Internet Not Connected", APC_ORIGINAL_ERROR_KEY: urlError}];
    }
    else if (!isServerReachable) {
        retError = [NSError errorWithDomain:APC_ERROR_DOMAIN code:kAPCServerNotReachable userInfo:@{NSLocalizedDescriptionKey: @"Backend Server Not Reachable",APC_ORIGINAL_ERROR_KEY: urlError}];
    }
    else
    {
        retError = [NSError errorWithDomain:APC_ERROR_DOMAIN code:kAPCUnknownError userInfo:@{NSLocalizedDescriptionKey: @"Unknown Network Error",APC_ORIGINAL_ERROR_KEY: urlError}];
    }
    return retError;
}

+ (NSError*) generateAPCErrorForHTTPResponse: (NSHTTPURLResponse*) response data: (NSData*) data
{
    //TODO: Get appropriate error strings
    NSError * retError;
    NSError * localError;
    id JSONData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&localError];
    [localError handle];
    if (response.statusCode == 401) {
        retError = [self APCNotAuthenticatedError];
    }
    else if (response.statusCode == 412)
    {
        retError = [NSError errorWithDomain:APC_ERROR_DOMAIN code:kAPCServerPreconditionNotMet userInfo:@{NSLocalizedDescriptionKey: @"Client not consented", APC_ORIGINAL_ERROR_KEY: JSONData}];
    }
    else if (NSLocationInRange(response.statusCode, NSMakeRange(400, 99))) {
        retError = [NSError errorWithDomain:APC_ERROR_DOMAIN code:response.statusCode userInfo:@{NSLocalizedDescriptionKey: @"Client Error. Please contact SOMEBODY",  APC_ORIGINAL_ERROR_KEY: JSONData}];
    }
    else if (response.statusCode == 503) {
        retError = [NSError errorWithDomain:APC_ERROR_DOMAIN code:kAPCServerUnderMaintenance userInfo:@{NSLocalizedDescriptionKey: @"Backend Server Under Maintenance.", APC_ORIGINAL_ERROR_KEY: JSONData}];
    }
    else if (NSLocationInRange(response.statusCode, NSMakeRange(500, 99))) {
        retError = [NSError errorWithDomain:APC_ERROR_DOMAIN code:response.statusCode userInfo:@{NSLocalizedDescriptionKey: @"Backend Server Error. Please contact SOMEBODY", APC_ORIGINAL_ERROR_KEY: JSONData}];
    }
    
    return retError;
}

+ (NSError *)APCNotAuthenticatedError
{
    return [NSError errorWithDomain:APC_ERROR_DOMAIN code:kAPCServerNotAuthenticated userInfo:@{NSLocalizedDescriptionKey: @"Backend Server Authentiction Error. Please sign in."}];
}

/*********************************************************************************/
#pragma mark - Error handlers
/*********************************************************************************/

- (void) handle
{
    NSLog(@"ERROR GENERATED: %@", self);
}

@end
