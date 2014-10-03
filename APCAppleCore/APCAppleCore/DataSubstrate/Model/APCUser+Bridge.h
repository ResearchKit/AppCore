//
//  APCUser+Bridge.h
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 10/3/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCUser.h"

@interface APCUser (Bridge)

- (void) signUpOnCompletion:(void (^)(NSError * error))completionBlock;
- (void) signInOnCompletion:(void (^)(NSError * error))completionBlock;
- (void) sendUserConsentedToBridgeOnCompletion: (void (^)(NSError * error))completionBlock;

@end
