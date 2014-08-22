//
//  APCSageNetworkManager.m
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 8/22/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCSageNetworkManager.h"

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

-(NSURLSessionDataTask *)signUp:(NSString *)email username:(NSString *)username password:(NSString *)password success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure
{
    return [self post:@"auth/signUp" parameters:@{@"email":email, @"username":username, @"password":password} success:success failure:failure];
}

- (NSURLSessionDataTask *)signIn:(NSString *)username password:(NSString *)password success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure
{
    return [self post:@"auth/signIn" parameters:@{@"username":username, @"password":password} success:success failure:failure];
}



@end
