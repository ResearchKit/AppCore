// 
//  APCUser+Bridge.h 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "APCUser.h"
#import <BridgeSDK/BridgeSDK.h>

@interface APCUser (Bridge) <SBBAuthManagerDelegateProtocol>

- (void) signUpOnCompletion:(void (^)(NSError * error))completionBlock;
- (void) signInOnCompletion:(void (^)(NSError * error))completionBlock;
- (void) updateProfileOnCompletion:(void (^)(NSError * error))completionBlock;
- (void) getProfileOnCompletion:(void (^)(NSError *error))completionBlock;
- (void) sendUserConsentedToBridgeOnCompletion: (void (^)(NSError * error))completionBlock;

@end
