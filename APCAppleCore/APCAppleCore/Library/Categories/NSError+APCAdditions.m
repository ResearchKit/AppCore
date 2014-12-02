//
//  NSError+APCAdditions.m
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 8/22/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCAppleCore.h"

@implementation NSError (APCAdditions)

/*********************************************************************************/
#pragma mark - Error handlers
/*********************************************************************************/

- (void) handle
{
    NSLog(@"APPCORE ERROR: %@", self.localizedDescription?:self);
}

- (NSString *) message {
    id localError = self.userInfo[SBB_ORIGINAL_ERROR_KEY];
    
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
