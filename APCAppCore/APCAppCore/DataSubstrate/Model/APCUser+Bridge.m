// 
//  APCUser+Bridge.m 
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
        [SBBComponent(SBBAuthManager) signUpWithEmail: self.email
											 username: self.email
											 password: self.password
										   completion: ^(NSURLSessionDataTask * __unused task,
														 id __unused responseObject,
														 NSError *error)
		 {
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
        
        profile.firstName = self.name;
        
        [SBBComponent(SBBProfileManager) updateUserProfileWithProfile: profile
														   completion: ^(id __unused responseObject,
																		 NSError *error)
		 {
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

- (void) updateCustomProfile:(SBBUserProfile*)profile onCompletion:(void (^)(NSError * error))completionBlock
{
    if ([self serverDisabled]) {
        if (completionBlock) {
            completionBlock(nil);
        }
    }
    else
    {
        profile.email     = self.email;
        profile.username  = self.email;
        profile.firstName = self.name;
        
        [SBBComponent(SBBProfileManager) updateUserProfileWithProfile: profile
                                                           completion: ^(id __unused responseObject,
                                                                         NSError *error)
         {
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
            self.name = profile.firstName;
            
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
        [SBBComponent(SBBConsentManager) dataSharing:SBBConsentShareScopeNone completion:^(id __unused responseObject, NSError * __unused error) {
            [self signOutOnCompletion:^(NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(!error) {
                        self.consented = NO;
                        APCLogEventWithData(kNetworkEvent, (@{@"event_detail":@"User Suspended Consent"}));
                    }
                    if (completionBlock) {
                        completionBlock(error);
                    }
                });
            }];
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
        APCAppDelegate *delegate = (APCAppDelegate*) [UIApplication sharedApplication].delegate;
        NSNumber *selected = delegate.dataSubstrate.currentUser.sharedOptionSelection;
        
        [SBBComponent(SBBConsentManager) dataSharing:[selected integerValue] completion:^(id __unused responseObject, NSError *error) {
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
        [SBBComponent(SBBAuthManager) signInWithUsername: self.email
                                                password: self.password
                                              completion: ^(NSURLSessionDataTask * __unused task,
                                                            id responseObject,
                                                            NSError *signInError)
         {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!signInError) {
                    
                    NSDictionary *responseDictionary = (NSDictionary *) responseObject;
                    if (responseDictionary) {
                        NSNumber *dataSharing = responseDictionary[@"dataSharing"];
                        
                        if (dataSharing.integerValue == 1) {
                            NSString *scope = responseDictionary[@"sharingScope"];
                            if ([scope isEqualToString:@"sponsors_and_partners"]) {
                                self.sharedOptionSelection = @(SBBConsentShareScopeStudy);
                            } else if ([scope isEqualToString:@"all_qualified_researchers"]) {
                                self.sharedOptionSelection = @(SBBConsentShareScopeAll);
                            }
                        } else if (dataSharing.integerValue == 0) {
                            self.sharedOptionSelection = @(SBBConsentShareScopeNone);
                        }
                    }
                    APCLogEventWithData(kNetworkEvent, (@{@"event_detail":@"User Signed In"}));
                }
                
                if (completionBlock) {
                    completionBlock(signInError);
                }
            });
        }];
    }
}


- (void)signOutOnCompletion:(void (^)(NSError *))completionBlock
{
    if ([self serverDisabled]) {
        if (completionBlock) {
            completionBlock(nil);
        }
    }
    else
    {
        NSParameterAssert(self.password);
        [SBBComponent(SBBAuthManager) signOutWithCompletion: ^(NSURLSessionDataTask * __unused task,
                                                               id __unused responseObject,
                                                               NSError *error)
         {
            dispatch_async(dispatch_get_main_queue(), ^{
                APCLogEventWithData(kNetworkEvent, (@{@"event_detail":@"User Signed Out"}));
                if (completionBlock) {
                    completionBlock(error);
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
        
        APCAppDelegate *delegate = (APCAppDelegate*) [UIApplication sharedApplication].delegate;
        NSNumber *selected = delegate.dataSubstrate.currentUser.sharedOptionSelection;
        
        [SBBComponent(SBBConsentManager) consentSignature:name
                                                birthdate: [birthDate startOfDay]
                                           signatureImage:consentImage
                                                dataSharing:[selected integerValue]
                                               completion:^(id __unused responseObject, NSError * __unused error) {
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
        [SBBComponent(SBBConsentManager) retrieveConsentSignatureWithCompletion: ^(NSString*          name,
                                                                                   NSString* __unused birthdate,
                                                                                   UIImage*           signatureImage,
                                                                                   NSError*           error)
		 {
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

- (void) resendEmailVerificationOnCompletion:(void (^)(NSError *))completionBlock
{
    if ([self serverDisabled]) {
        if (completionBlock) {
            completionBlock(nil);
        }
    }
    else
    {
        if (self.email.length > 0) {
            [SBBComponent(SBBAuthManager) resendEmailVerification:self.email completion: ^(NSURLSessionDataTask * __unused task,
                                                                                           id __unused responseObject,
                                                                                           NSError *error)
			 {
                if (!error) {
                     APCLogEventWithData(kNetworkEvent, (@{@"event_detail":@"Bridge Server Aked to resend email verficiation email"}));
                }
                if (completionBlock) {
                    completionBlock(error);
                }
            }];
        }
        else {
            if (completionBlock) {
                completionBlock([NSError errorWithDomain:@"APCAppCoreErrorDomain" code:-100 userInfo:@{NSLocalizedDescriptionKey : @"User email empty"}]);
            }
        }
    }
}

- (void)changeDataSharingTypeOnCompletion:(void (^)(NSError *))completionBlock
{
    NSNumber *selected = self.sharedOptionSelection;
    
    [SBBComponent(SBBConsentManager) dataSharing:[selected integerValue] completion:^(id __unused responseObject, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error) {
                switch (selected.integerValue) {
                    case 0:
                    {
                        APCLogEventWithData(kNetworkEvent, (@{@"event_detail":@"Data Sharing disabled"}));
                    }
                        break;
                    case 1:
                    {
                        APCLogEventWithData(kNetworkEvent, (@{@"event_detail":@"Data Sharing with Institute only"}));
                    }
                        break;
                    case 2:
                    {
                        APCLogEventWithData(kNetworkEvent, (@{@"event_detail":@"Data Sharing with all"}));
                    }
                        break;
                        
                    default:
                        break;
                }
            }
            if (completionBlock) {
                completionBlock(error);
            }
        });
    }];
}

/*********************************************************************************/
#pragma mark - Authmanager Delegate Protocol
/*********************************************************************************/

- (NSString *)sessionTokenForAuthManager:(id<SBBAuthManagerProtocol>) __unused authManager
{
    return self.sessionToken;
}

- (void)authManager:(id<SBBAuthManagerProtocol>) __unused authManager didGetSessionToken:(NSString *)sessionToken
{
    self.sessionToken = sessionToken;
}

- (NSString *)usernameForAuthManager:(id<SBBAuthManagerProtocol>) __unused authManager
{
    return self.email;
}

- (NSString *)passwordForAuthManager:(id<SBBAuthManagerProtocol>) __unused authManager
{
    return self.password;
}

#pragma mark - Error Messages

- (NSString *)noInternetString
{
    return NSLocalizedString(@"No network connection. Please connect to the internet and try again.", @"No Internet");
}
@end
