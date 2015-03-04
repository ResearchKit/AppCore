// 
//  NSError+APCAdditions.h 
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface NSError (APCAdditions)

/*********************************************************************************/
#pragma mark - Error handlers
/*********************************************************************************/
- (void) handle DEPRECATED_ATTRIBUTE;
- (NSString*) message;

@end
