//
//  APCSageNetworkManager.h
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 8/22/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCNetworkManager.h"

@interface APCSageNetworkManager : APCNetworkManager

/*********************************************************************************/
#pragma mark - User Authentication
/*********************************************************************************/
-(void)signUpAndSignIn:(NSString *)email username:(NSString *)username password:(NSString *)password success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *responseObject))failure;

- (NSURLSessionDataTask*) signUp:(NSString*) email username: (NSString*) username password: (NSString*) password success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

- (NSURLSessionDataTask*) signIn:(NSString*) username password: (NSString*) password success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

@end
