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

// If YES, sign up process will check for special string in email addresses to auto-detect test users
// If NO, sign up will treat all emails and data as valid in production
static BOOL shouldPerformTestUserEmailCheckOnSignup = NO;
static NSString* const kHiddenTestEmailString = @"+test";
static NSString* const kTestDataGroup = @"test_user";

@implementation APCUser (Bridge)

- (BOOL) serverDisabled
{
#if DEVELOPMENT
    return YES;
#else
    return ((APCAppDelegate*)[UIApplication sharedApplication].delegate).dataSubstrate.parameters.bypassServer;
#endif
}

+ (void) setShouldPerformTestUserEmailCheckOnSignup:(BOOL)shouldPerform
{
    shouldPerformTestUserEmailCheckOnSignup = shouldPerform;
}

- (void)signUpOnCompletion:(void (^)(NSError *))completionBlock
{
    [self signUpWithDataGroups:self.dataGroups onCompletion:completionBlock];
}

- (void)signUpWithDataGroups:(NSArray<NSString *> *)dataGroups onCompletion:(void (^)(NSError *))completionBlock
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
                                           dataGroups:dataGroups
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

- (void) signUpWithDataGroups:(NSArray<NSString *> *)dataGroups
         withTestUserPromptVc:(__weak UIViewController*)vc
                 onCompletion:(void (^)(NSError *))completionBlock
{
    if (!shouldPerformTestUserEmailCheckOnSignup ||
        ![[self.email lowercaseString] containsString:kHiddenTestEmailString])
    {
        [self signUpWithDataGroups:dataGroups onCompletion:completionBlock];
        return;
    }
    
    [self showTestUserVerificationAlertWithVc:vc onCompletion:^(BOOL userWantsToBeTester)
    {
        NSMutableArray* mutableDataGroups = [dataGroups mutableCopy] ?: [NSMutableArray new];
        if (userWantsToBeTester)
        {
            [mutableDataGroups addObject:kTestDataGroup];
        }
        [self signUpWithDataGroups:mutableDataGroups onCompletion:completionBlock];
    }];
}

- (void) updateDataGroups:(NSArray<NSString *> *)dataGroups onCompletion:(void (^)(NSError * error))completionBlock
{
    typeof(self) __weak weakSelf = self;
    void (^completion)(NSError *) = ^(NSError * error) {
        if (!error) {
            weakSelf.dataGroups = dataGroups;
        }
        if (completionBlock) {
            completionBlock(error);
        }
    };
    
    if ([self serverDisabled]) {
        completion(nil);
    }
    else
    {
        SBBDataGroups *groups = [SBBDataGroups new];
        groups.dataGroups = [NSSet setWithArray:dataGroups];
        
        [SBBComponent(SBBUserManager) updateDataGroupsWithGroups:groups
                                                      completion: ^(id __unused responseObject,
                                                                      NSError *error)
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 if (!error) {
                     APCLogEventWithData(kNetworkEvent, (@{@"event_detail":@"User Data Groups Updated To Bridge"}));
                 }
                 completion(error);
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
        
        profile.firstName = self.name;
        
        [SBBComponent(SBBUserManager) updateUserProfileWithProfile: profile
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
        profile.firstName = self.name;
        
        [SBBComponent(SBBUserManager) updateUserProfileWithProfile: profile
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
        [SBBComponent(SBBUserManager) getUserProfileWithCompletion:^(id userProfile, NSError *error) {
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

- (void) withdrawStudyWithReason:(NSString *)reason onCompletion:(void (^)(NSError *))completionBlock
{
    if ([self serverDisabled]) {
        if (completionBlock) {
            completionBlock(nil);
        }
    }
    else
    {
        [SBBComponent(SBBConsentManager) withdrawConsentForSubpopulation:[self subpopulationGuid] withReason:reason completion:^(id __unused responseObject, NSError * __unused error) {
            if (!error) {
                [self signOutOnCompletion:^(NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if(!error) {
                            self.consented = NO;
                            [[NSNotificationCenter defaultCenter] postNotificationName:APCUserDidWithdrawStudyNotification object:self];
                            APCLogEventWithData(kNetworkEvent, (@{@"event_detail":@"User Suspended Consent"}));
                        }
                        if (completionBlock) {
                            completionBlock(error);
                        }
                    });
                }];
            } else {
                if (completionBlock) {
                    completionBlock(error);
                }
            }
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
        NSInteger scope = self.savedSharingScope ? self.savedSharingScope.integerValue : selected.integerValue;
        
        [SBBComponent(SBBUserManager) dataSharing:scope completion:^(id __unused responseObject, NSError *error) {
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


- (void) pauseSharingOnCompletion:(void (^)(NSError *))completionBlock
{
    self.sharingScope = APCUserConsentSharingScopeNone;
    
    if ([self serverDisabled]) {
        if (completionBlock) {
            completionBlock(nil);
        }
    }
    else
    {
        [SBBComponent(SBBUserManager) dataSharing:SBBUserDataSharingScopeNone completion:^(id __unused responseObject, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!error) {
                    APCLogEventWithData(kNetworkEvent, (@{@"event_detail":@"User Paused Sharing"}));
                }
                if (completionBlock) {
                    completionBlock(error);
                }
            });
        }];
    }
}

- (void) resumeSharingOnCompletion:(void (^)(NSError *))completionBlock
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
        
        [SBBComponent(SBBUserManager) dataSharing:[selected integerValue] completion:^(id __unused responseObject, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!error) {
                    APCLogEventWithData(kNetworkEvent, (@{@"event_detail":@"User Resumed Sharing"}));
                    self.sharingScope = selected.integerValue;
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
        [SBBComponent(SBBAuthManager) signInWithEmail: self.email
                                             password: self.password
                                           completion: ^(NSURLSessionDataTask * __unused task,
                                                         id responseObject,
                                                         NSError *signInError)
         {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!signInError || signInError.code == SBBErrorCodeServerPreconditionNotMet) {
                    NSDictionary *responseDictionary = (NSDictionary *) responseObject;
                    if (responseDictionary) {
                        NSNumber *dataSharing = responseDictionary[@"dataSharing"];
                        
                        if (dataSharing.integerValue == 1) {
                            NSString *scope = responseDictionary[@"sharingScope"];
                            if ([scope isEqualToString:@"sponsors_and_partners"]) {
                                self.sharingScope = APCUserConsentSharingScopeStudy;
                            } else if ([scope isEqualToString:@"all_qualified_researchers"]) {
                                self.sharingScope = APCUserConsentSharingScopeAll;
                            }
                        } else if (dataSharing.integerValue == 0) {
                            self.sharingScope = APCUserConsentSharingScopeNone;
                        }
                    }
                    
                    NSArray *dataGroups = responseDictionary[@"dataGroups"];
                    self.dataGroups = dataGroups;
                    
                    // TODO: Handle multiple consent groups with separate sub populations
                    NSDictionary *consentStatuses = responseDictionary[@"consentStatuses"];
                    for (id key in consentStatuses) {
                        NSDictionary *status = [consentStatuses objectForKey:key];
                        NSString *guid = status[@"subpopulationGuid"];
                        BOOL required = [status[@"required"] boolValue];
                        if (required) {
                            self.subpopulationGuid = guid;
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
             self.email = nil;
             self.password = nil;
             [[NSNotificationCenter defaultCenter] postNotificationName:APCUserLogOutNotification object:self];
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
                                     forSubpopulationGuid:[self subpopulationGuid]
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
        [SBBComponent(SBBConsentManager) getConsentSignatureForSubpopulation:[self subpopulationGuid]
                                                                  completion: ^(id consentSignature, NSError *error)
		 {
            if (error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completionBlock) {
                        completionBlock(error);
                    }
                });
            } else {
                // parse consent signature dictionary, if we have one
                if ([consentSignature isKindOfClass:[SBBConsentSignature class]]) {
                    SBBConsentSignature *cSig = consentSignature;
                    self.consentSignatureName = cSig.name;
                    self.consentSignatureImage = cSig.imageData ? [[NSData alloc] initWithBase64EncodedString:cSig.imageData options:kNilOptions] : nil;
                }
                
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
    if (self.sharingScope == APCUserConsentSharingScopeNone) {
        if (completionBlock) {
            completionBlock(nil);
        }
        return;
    }
    NSNumber *selected = self.sharedOptionSelection;
    
    [SBBComponent(SBBUserManager) dataSharing:[selected integerValue] completion:^(id __unused responseObject, NSError *error) {
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

- (void)sendDownloadDataOnCompletion:(void (^)(NSError *))completionBlock
{
    if ([self serverDisabled]) {
        if (completionBlock) {
            completionBlock(nil);
        }
    }
    else
    {
        [SBBComponent(SBBUserManager) emailDataToUserFrom:self.downloadDataStartDate
                                                       to:self.downloadDataEndDate
                                               completion:^(id __unused responseObject, NSError * __unused error)
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 if (!error) {
                     APCLogEventWithData(kNetworkEvent, (@{@"event_detail":@"User Activated Download Data Email"}));
                 }
                 if (completionBlock) {
                     completionBlock(error);
                 }
             });
         }];
    }
}

/*********************************************************************************/
#pragma mark - UI Methods
/*********************************************************************************/

- (void) showTestUserVerificationAlertWithVc:(__weak UIViewController*)vc
                                onCompletion:(void (^)(BOOL userWantsToBeTester))completionBlock
{
    UIViewController* previousPresentedVc = vc.presentedViewController;
    
    void (^showVcBlock)() = ^
    {
        NSString* yesStr = NSLocalizedString(@"YES", @"Positive Answer");
        NSString* noStr =  NSLocalizedString(@"NO", @"Negative Answer");
        NSString* title =  NSLocalizedString(@"Are you a tester?", @"Question if the user is a quality assurance tester");
        NSString* msg = [NSString stringWithFormat:NSLocalizedString(@"Based on your email address, we have detected you are a tester for %@.  If this is correct, select %@ so we can store your data separately.", @"Message informing user if and what happens if they are a tester"), [APCUtilities appName], [yesStr lowercaseString]];
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                       message:msg
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* noAction = [UIAlertAction actionWithTitle:noStr
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(__unused UIAlertAction * _Nonnull action)
        {
           if (previousPresentedVc != nil)
           {
               [vc presentViewController:previousPresentedVc animated:YES completion:nil];
           }
           completionBlock(NO);
        }];
        [alert addAction:noAction];
        
        UIAlertAction* yesAction = [UIAlertAction actionWithTitle:yesStr
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(__unused UIAlertAction * _Nonnull action)
        {
            if (previousPresentedVc != nil)
            {
                [vc presentViewController:previousPresentedVc animated:YES completion:nil];
            }
            completionBlock(YES);
        }];
        [alert addAction:yesAction];
        
        [vc presentViewController:alert animated:YES completion:nil];
    };
    
    if (previousPresentedVc != nil)
    {
        [vc dismissViewControllerAnimated:YES completion:^
        {
            showVcBlock();
        }];
    }
    else
    {
        showVcBlock();
    }
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

- (NSString *)emailForAuthManager:(id<SBBAuthManagerProtocol>) __unused authManager
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
    return NSLocalizedStringWithDefaultValue(@"No network connection. Please connect to the internet and try again.", @"APCAppCore", APCBundle(), @"No network connection. Please connect to the internet and try again.", @"No Internet");
}
@end
