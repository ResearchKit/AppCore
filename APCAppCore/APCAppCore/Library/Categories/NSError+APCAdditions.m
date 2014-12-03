// 
//  NSError+APCAdditions.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "APCAppCore.h"

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
