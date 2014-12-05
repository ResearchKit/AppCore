// 
//  APCUser+Bridge.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "APCUser+Bridge.h"
#import "APCAppCore.h"

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

- (void) updateProfileOnCompletion:(void (^)(NSError *))completionBlock
{
    if ([self serverDisabled]) {
        if (completionBlock) {
            completionBlock(nil);
        }
    }
    else
    {
        SBBUserProfile *profile = [SBBUserProfile new];
        profile.email = self.email;
        profile.username = self.email;
        profile.firstName = self.firstName;
        profile.lastName = self.lastName;
        
        [SBBComponent(SBBProfileManager) updateUserProfileWithProfile:profile completion:^(id responseObject, NSError *error) {
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
        [SBBComponent(SBBAuthManager) signInWithUsername:self.email password:self.password completion:^(NSURLSessionDataTask *task, id responseObject, NSError *signInError) {
            if (!signInError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.userConsented = YES;
                    self.consented = YES;
                    if (completionBlock) {
                        completionBlock(signInError);
                    }
                });
            } else if (signInError.code == kSBBServerPreconditionNotMet){
                
                [self sendUserConsentedToBridgeOnCompletion:^(NSError *error) {
                    if (error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (completionBlock) {
                                completionBlock(error);
                            }
                        });
                    }
                    else
                    {
                        [self signInOnCompletion:completionBlock];
                    }
                }];
                
            }
            else if (signInError)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completionBlock) {
                        completionBlock(signInError);
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
        NSString * name = self.firstName.length? [self.firstName stringByAppendingFormat:@" %@", self.lastName] : @"FirstName";
        NSDate * birthDate = self.birthDate ?: [NSDate dateWithTimeIntervalSince1970:(60*60*24*365*10)];
        [SBBComponent(SBBConsentManager) consentSignature:name birthdate:birthDate completion:^(id responseObject, NSError *error) {
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
