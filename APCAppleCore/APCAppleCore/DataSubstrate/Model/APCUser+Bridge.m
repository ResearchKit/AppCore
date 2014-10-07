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

- (void)signUpOnCompletion:(void (^)(NSError *))completionBlock
{
#if DEVELOPMENT
    if (completionBlock) {
        completionBlock(nil);
    }
#else
    NSParameterAssert(self.email);
    NSParameterAssert(self.userName);
    NSParameterAssert(self.password);
    [SBBComponent(SBBAuthManager) signUpWithEmail:self.email username:self.userName password:self.password completion:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                completionBlock(error);
            }
        });
    }];
#endif
}

- (void)signInOnCompletion:(void (^)(NSError *))completionBlock
{
#if DEVELOPMENT
    if (completionBlock) {
        completionBlock(nil);
    }
#else
    NSParameterAssert(self.userName);
    NSParameterAssert(self.password);
    [SBBComponent(SBBAuthManager) signInWithUsername:self.userName password:self.password completion:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                completionBlock(error);
            }
        });
    }];
#endif
}

- (void)sendUserConsentedToBridgeOnCompletion:(void (^)(NSError *))completionBlock
{
#if DEVELOPMENT
    if (completionBlock) {
        completionBlock(nil);
    }
#else
    NSParameterAssert(self.firstName);
    NSParameterAssert(self.lastName);
    //TODO: Figure out what needs to be done if birthDate is nil
    [SBBComponent(SBBConsentManager) consentSignature:[self.firstName stringByAppendingFormat:@" %@", self.lastName] birthdate:self.birthDate completion:^(id responseObject, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                completionBlock(error);
            }
        });
    }];
#endif
}


@end
