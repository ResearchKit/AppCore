//
//  Generators.h
//  Generators
//
//  Created by Edward Cessna on 8/26/14.
//  Copyright (c) 2014 Edward Cessna. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol Generator <NSObject>

- (BOOL)hasNext;
- (id)next;

@end

//  Example 1
@interface IndexGenerator : NSObject  <Generator>

- (instancetype)initWithIndex:(NSNumber*)index;
- (BOOL)hasNext;
- (NSDecimalNumber*)next;

@end

//  Example 2
@interface NormalizingGenerator : NSObject <Generator>

- (instancetype)initWithDataArray:(NSArray*)data;
- (BOOL)hasNext;
- (NSDecimalNumber*)next;

@end
