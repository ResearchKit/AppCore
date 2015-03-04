//
//  APCStack.m
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
//

#import "APCStack.h"

@interface APCStack ()

@property (nonatomic, strong) NSMutableArray*   storage;

@end

@implementation APCStack

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _storage = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (NSUInteger)count
{
    return self.storage.count;
}

- (void)push:(id)element
{
    [self.storage addObject:element];
}

- (id)pop
{
    NSAssert(self.storage.count, @"Attempted to pop an element off of an empty stack");
    
    id  answer = [self.storage lastObject];
    
    [self.storage removeLastObject];
    
    return answer;
}

@end
