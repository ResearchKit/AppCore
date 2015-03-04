//
//  APCStack.h
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APCStack : NSObject

- (NSUInteger)count;
- (void)push:(id)element;
- (id)pop;

@end
