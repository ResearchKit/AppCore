//
//  ChartEnumerator.m
//  Flow
//
//  Created by Karthik Keyan on 8/26/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "ChartDataEnumerator.h"

@interface ChartDataEnumerator ()

@property (nonatomic, readonly) BOOL isReverse;

@property (nonatomic, readwrite) NSInteger nextObjectIndex;

@property (nonatomic, strong) NSArray *objects;


- (instancetype) initWithArray:(NSArray *)objects reverse:(BOOL)isReverse;

@end

@implementation ChartDataEnumerator

- (instancetype) initWithArray:(NSArray *)objects reverse:(BOOL)isReverse {
    self = [super init];
    if (self) {
        _objects = objects;
        _isReverse = isReverse;
        
        if (isReverse) {
            self.nextObjectIndex = objects.count - 1;
        }
        
        [self findMinMax];
    }
    return self;
}

- (void) findMinMax {
    for (NSDecimalNumber *num in self.objects) {
        if (!self.min) { self.min = num; }
        
        if (!self.max) { self.max = num; }
        
        if ([num compare:self.min] == NSOrderedAscending) {
            self.min = num;
        }
        
        if ([num compare:self.max] == NSOrderedDescending) {
            self.max = num;
        }
    }
}



- (id) nextObject {
    id object;
    
    if ([self hasNextObject]) {
        object = self.objects[self.nextObjectIndex];
        
        if (self.isReverse) {
            self.nextObjectIndex--;
        }
        else {
            self.nextObjectIndex++;
        }
    }
    
    return object;
}

- (BOOL) hasNextObject {
    BOOL hasNextObject = NO;
    
    if (self.isReverse) {
        hasNextObject = (self.nextObjectIndex >= 0);
    }
    else {
        hasNextObject = (self.nextObjectIndex < self.objects.count);
    }
    
    
    return hasNextObject;
}

@end


@implementation NSArray (ChartDataEnumerator)

- (ChartDataEnumerator *) chartEnumerator {
    return [[ChartDataEnumerator alloc] initWithArray:self reverse:NO];
}

- (ChartDataEnumerator *) reverseChartEnumerator {
    return [[ChartDataEnumerator alloc] initWithArray:self reverse:YES];
}

@end
