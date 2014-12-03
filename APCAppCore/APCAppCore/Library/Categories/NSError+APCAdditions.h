// 
//  NSError+APCAdditions.h 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import <Foundation/Foundation.h>

@interface NSError (APCAdditions)

/*********************************************************************************/
#pragma mark - Error handlers
/*********************************************************************************/
- (void) handle;
- (NSString*) message;

@end
