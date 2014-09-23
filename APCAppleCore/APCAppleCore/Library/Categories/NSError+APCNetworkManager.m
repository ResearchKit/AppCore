//
//  NSError+APCNetworkManager.m
//  APCAppleCore
//
//  Created by Karthik Keyan on 9/16/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCAppleCore.h"
#import "NSError+APCNetworkManager.h"

@implementation NSError (APCNetworkManager)

- (NSString *) message {
    id localError = self.userInfo[APC_ORIGINAL_ERROR_KEY];
    
    NSString *message;
    
    if ([localError isKindOfClass:[NSError class]]) {
        message = [(NSError *)localError localizedDescription];
    }
    else {
        message = [localError objectForKey:@"message"];
    }
    
    return message;
}

@end
