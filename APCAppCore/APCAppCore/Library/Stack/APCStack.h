//
//  APCStack.h
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APCStack : NSObject

- (NSUInteger)count;
- (void)push:(id)element;
- (id)pop;
- (id)peek
;
@end
