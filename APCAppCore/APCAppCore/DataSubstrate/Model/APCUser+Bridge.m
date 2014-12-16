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
                if (!error) {
                    APCLogEventWithData(kNetworkEvent, (@{@"event_detail":@"User Signed Up"}));
                }
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
                if (!error) {
                    APCLogEventWithData(kNetworkEvent, (@{@"event_detail":@"User Profile Updated To Bridge"}));
                }
                if (completionBlock) {
                    completionBlock(error);
                }
            });
        }];
    }
}

- (void) getProfileOnCompletion:(void (^)(NSError *))completionBlock
{
    if ([self serverDisabled]) {
        if (completionBlock) {
            completionBlock(nil);
        }
    }
    else
    {
        [SBBComponent(SBBProfileManager) getUserProfileWithCompletion:^(id userProfile, NSError *error) {
            SBBUserProfile *profile = (SBBUserProfile *)userProfile;
            self.email = profile.email;
            self.firstName = profile.firstName;
            self.lastName = profile.lastName;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!error) {
                    APCLogEventWithData(kNetworkEvent, (@{@"event_detail":@"User Profile Received From Bridge"}));
                }
                if (completionBlock) {
                    completionBlock(error);
                }
            });
        }];
    }
}

- (void) withdrawStudyOnCompletion:(void (^)(NSError *))completionBlock
{
    if ([self serverDisabled]) {
        if (completionBlock) {
            completionBlock(nil);
        }
    }
    else
    {
        [SBBComponent(SBBConsentManager) suspendConsentWithCompletion:^(id responseObject, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!error) {
                    APCLogEventWithData(kNetworkEvent, (@{@"event_detail":@"User Suspended Consent"}));
                }
                if (completionBlock) {
                    completionBlock(error);
                }
            });
        }];
    }
}

- (void) resumeStudyOnCompletion:(void (^)(NSError *))completionBlock
{
    if ([self serverDisabled]) {
        if (completionBlock) {
            completionBlock(nil);
        }
    }
    else
    {
        [SBBComponent(SBBConsentManager) resumeConsentWithCompletion:^(id responseObject, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!error) {
                    APCLogEventWithData(kNetworkEvent, (@{@"event_detail":@"User Resumed Consent"}));
                }
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
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!signInError) {
                    APCLogEventWithData(kNetworkEvent, (@{@"event_detail":@"User Signed In"}));
                }
                
                if (completionBlock) {
                    completionBlock(signInError);
                }
            });
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
        NSString * name = self.consentSignatureName.length ? self.consentSignatureName : @"FirstName LastName";
        NSDate * birthDate = self.birthDate ?: [NSDate dateWithTimeIntervalSince1970:(60*60*24*365*10)];
        UIImage *consentImage = [UIImage imageWithData:self.consentSignatureImage];
        
        [SBBComponent(SBBConsentManager) consentSignature:name
                                                birthdate:birthDate
                                           signatureImage:consentImage
                                               completion:^(id responseObject, NSError *error) {
                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                       if (!error) {
                                                           APCLogEventWithData(kNetworkEvent, (@{@"event_detail":@"User Consent Sent To Bridge"}));
                                                       }
                                                       
                                                       if (completionBlock) {
                                                           completionBlock(error);
                                                       }
                                                   });
                                               }];
    }
}

- (void)retrieveConsentOnCompletion:(void (^)(NSError *))completionBlock
{
    if ([self serverDisabled]) {
        if (completionBlock) {
            completionBlock(nil);
        }
    }
    else
    {
        [SBBComponent(SBBConsentManager) retrieveConsentSignatureWithCompletion:^(NSString *name, NSString *birthdate, UIImage *signatureImage, NSError *error) {
            
            if (error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completionBlock) {
                        completionBlock(error);
                    }
                });
            } else {
                self.consentSignatureName = name;
                self.consentSignatureImage = UIImagePNGRepresentation(signatureImage);
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (!error) {
                        APCLogEventWithData(kNetworkEvent, (@{@"event_detail":@"User Consent Signature Received From Bridge"}));
                    }
                    
                    if (completionBlock) {
                        completionBlock(error);
                    }
                });
            }
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

#pragma mark - Error Messages

- (NSString *)noInternetString
{
    return NSLocalizedString(@"No network connection. Please connect to the internet and try again.", @"No Internet");
}
@end
