//
//  NSArray+Functional.h
//  Schedule
//
//  Created by Edward Cessna on 9/19/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Functional)

- (id)reduce:(id(^)(id a, id b))block;
- (void)each:(void(^)(id object))block;
- (NSArray*)map:(id(^)(id object))block;
- (NSArray*)mapWithIndex:(id(^)(id object, NSUInteger index))block;
- (BOOL)every:(BOOL(^)(id object))block;
- (BOOL)everyWithIndex:(BOOL(^)(id object, NSUInteger index))block;
- (BOOL)any:(BOOL(^)(id object))block;

@end
