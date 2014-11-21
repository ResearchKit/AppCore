//
//  APCUser+Bridge.m
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 10/3/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCUser+Bridge.h"
#import "APCAppleCore.h"

@implementation APCUser (Bridge)

- (BOOL) serverDisabled
{
#if DEVELOPMENT
    return YES;
#else
    return ((APCAppDelegate*)[UIApplication sharedApplication].delegate).dataSubstrate.parameters.bypassServer;
#endif
}

- (void)signUpOnCompletion:(void (^)(NSError *))completionBlock
{
    if ([self serverDisabled]) {
        if (completionBlock) {
            completionBlock(nil);
        }
    }
    else
    {
        NSParameterAssert(self.email);
        NSParameterAssert(self.password);
        [SBBComponent(SBBAuthManager) signUpWithEmail:self.email username:self.email password:self.password completion:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completionBlock) {
                    completionBlock(error);
                }
            });
        }];
    }
}

- (void)signInOnCompletion:(void (^)(NSError *))completionBlock
{
    if ([self serverDisabled]) {
        if (completionBlock) {
            completionBlock(nil);
        }
    }
    else
    {
        
        NSParameterAssert(self.password);
        [SBBComponent(SBBAuthManager) signInWithUsername:self.email password:self.password completion:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
            if (error.code ==kSBBServerPreconditionNotMet) {
                if (!self.firstName) {
                    self.firstName = @"Please enter first name";
                }
                [self sendUserConsentedToBridgeOnCompletion:^(NSError *error) {
                    [self signInOnCompletion:completionBlock];
                }];
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completionBlock) {
                        completionBlock(error);
                    }
                });
            }
        }];
    }
}

- (void)sendUserConsentedToBridgeOnCompletion:(void (^)(NSError *))completionBlock
{
    if ([self serverDisabled]) {
        if (completionBlock) {
            completionBlock(nil);
        }
    }
    else
    {
        NSParameterAssert(self.firstName);
        //TODO: Figure out what needs to be done if birthDate is nil
        NSDate * birthDate = self.birthDate ?: [NSDate dateWithTimeIntervalSince1970:(60*60*24*365*10)];
        [SBBComponent(SBBConsentManager) consentSignature:self.firstName birthdate:birthDate completion:^(id responseObject, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completionBlock) {
                    completionBlock(error);
                }
            });
        }];
    }
}

/*********************************************************************************/
#pragma mark - Authmanager Delegate Protocol
/*********************************************************************************/

- (NSString *)sessionTokenForAuthManager:(id<SBBAuthManagerProtocol>)authManager
{
    return self.sessionToken;
}

- (void)authManager:(id<SBBAuthManagerProtocol>)authManager didGetSessionToken:(NSString *)sessionToken
{
    self.sessionToken = sessionToken;
}

- (NSString *)usernameForAuthManager:(id<SBBAuthManagerProtocol>)authManager
{
    return self.email;
}

- (NSString *)passwordForAuthManager:(id<SBBAuthManagerProtocol>)authManager
{
    return self.password;
}

@end


//TODO: For Dhanush
//Figure out what is to be replaced with username
