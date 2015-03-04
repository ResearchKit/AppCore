// 
//  APCUser+Bridge.h 
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//
 
#import "APCUser.h"
#import <BridgeSDK/BridgeSDK.h>

@interface APCUser (Bridge) <SBBAuthManagerDelegateProtocol>

- (void) signUpOnCompletion:(void (^)(NSError * error))completionBlock;
- (void) signInOnCompletion:(void (^)(NSError * error))completionBlock;
- (void) signOutOnCompletion:(void (^)(NSError * error))completionBlock;
- (void) updateProfileOnCompletion:(void (^)(NSError * error))completionBlock;
- (void) getProfileOnCompletion:(void (^)(NSError *error))completionBlock;
- (void) sendUserConsentedToBridgeOnCompletion: (void (^)(NSError * error))completionBlock;
- (void)retrieveConsentOnCompletion:(void (^)(NSError *error))completionBlock;
- (void) withdrawStudyOnCompletion:(void (^)(NSError *error))completionBlock;
- (void) resumeStudyOnCompletion:(void (^)(NSError *error))completionBlock;
- (void) resendEmailVerificationOnCompletion:(void (^)(NSError *))completionBlock;

@end
