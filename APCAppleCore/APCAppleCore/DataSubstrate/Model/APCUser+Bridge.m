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
    NSParameterAssert(self.email);
    NSParameterAssert(self.userName);
    NSParameterAssert(self.password);
    NSURLSessionDataTask * dataTask = [SBBComponent(SBBAuthManager) signUpWithEmail:self.email username:self.userName password:self.password completion:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                completionBlock(error);
            }
        });
    }];
    [dataTask resume];
}

- (void)signInOnCompletion:(void (^)(NSError *))completionBlock
{
    NSParameterAssert(self.userName);
    NSParameterAssert(self.password);
    NSURLSessionDataTask * dataTask = [SBBComponent(SBBAuthManager) signInWithUsername:self.userName password:self.password completion:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                completionBlock(error);
            }
        });
    }];
    [dataTask resume];
}

- (void)sendUserConsentedToBridgeOnCompletion:(void (^)(NSError *))completionBlock
{
    NSParameterAssert(self.firstName);
    NSParameterAssert(self.lastName);
    //TODO: Figure out what needs to be done if birthDate is nil
    NSURLSessionDataTask * dataTask = [SBBComponent(SBBConsentManager) consentSignature:[self.firstName stringByAppendingFormat:@" %@", self.lastName] birthdate:self.birthDate completion:^(id responseObject, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                completionBlock(error);
            }
        });
    }];
    [dataTask resume];
}


@end
