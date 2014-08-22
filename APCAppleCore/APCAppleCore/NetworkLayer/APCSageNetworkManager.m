//
//  APCSageNetworkManager.m
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 8/22/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCSageNetworkManager.h"
#import "APCAppleCore.h"

@interface APCSageNetworkManager ()
{
    NSURLProtectionSpace * _serverProtectionSpace;
    NSString * _sessionToken;
}

@end

@implementation APCSageNetworkManager

/*********************************************************************************/
#pragma mark - Initializers
/*********************************************************************************/
-(instancetype)initWithBaseURL:(NSString *)baseURL
{
    self = [super initWithBaseURL:baseURL];
    NSURL * url = [NSURL URLWithString:baseURL];
    _serverProtectionSpace = [[NSURLProtectionSpace alloc] initWithHost:url.host
                                                                   port:[url.port integerValue]
                                                               protocol:url.scheme
                                                                  realm:nil
                                                   authenticationMethod:NSURLAuthenticationMethodHTTPDigest];
    return self;
}

/*********************************************************************************/
#pragma mark - User Authentication
/*********************************************************************************/
-(void)signUpAndSignIn:(NSString *)email username:(NSString *)username password:(NSString *)password success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure
{
    [self signUp:email username:username password:password success:^(NSURLSessionDataTask *task, id responseObject) {
        [self signIn:username password:password success:success failure:failure];
    } failure:failure];
}

-(void)authenticateWithExistingCredentialsIfNecessaryWithSuccess:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure
{
    if ([self isAuthenticated]) {
        if (success) {
            success(nil, nil);
        }
    }
    else
    {
        NSDictionary *credentials = [[NSURLCredentialStorage sharedCredentialStorage] credentialsForProtectionSpace:_serverProtectionSpace];
        NSURLCredential *credential = [credentials.objectEnumerator nextObject];
        if (!credential) {
            if (failure) {
                failure(nil,[NSError APCNotAuthenticatedError]);
            }
        }
        else
        {
            [self signIn:credential.user password:credential.password success:success failure:failure];
        }
    }
    
}

-(NSURLSessionDataTask *)signUp:(NSString *)email username:(NSString *)username password:(NSString *)password success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure
{
    return [self post:@"auth/signUp" parameters:@{@"email":email, @"username":username, @"password":password} success:success failure:failure];
}

- (NSURLSessionDataTask *)signIn:(NSString *)username password:(NSString *)password success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure
{
    return [self post:@"auth/signIn" parameters:@{@"username":username, @"password":password} success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSURLCredential *credential = [NSURLCredential credentialWithUser:username password:password persistence:NSURLCredentialPersistencePermanent];
        [[NSURLCredentialStorage sharedCredentialStorage] setCredential:credential forProtectionSpace:_serverProtectionSpace];
        _sessionToken = responseObject[@"sessionToken"];
        if (success) {
            success(task, responseObject);
        }
    }  failure:failure];
}

/*********************************************************************************/
#pragma mark - Testing Purpose Methods
/*********************************************************************************/
- (NSURLSessionDataTask *)signOutWithSuccess:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure
{
    return [self get:@"auth/signOut" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *credentials = [[NSURLCredentialStorage sharedCredentialStorage] credentialsForProtectionSpace:_serverProtectionSpace];
        NSURLCredential *credential = [credentials.objectEnumerator nextObject];
        if (credential) {
            [[NSURLCredentialStorage sharedCredentialStorage] removeCredential:credential forProtectionSpace:_serverProtectionSpace];
        }
        if (success) {
            success(task, responseObject);
        }
    } failure:failure];
}

-(void)clearSessionToken
{
    _sessionToken = nil;
}

/*********************************************************************************/
#pragma mark - Helper Methods
/*********************************************************************************/
- (BOOL) isAuthenticated
{
    return (_sessionToken != nil);
}

@end
