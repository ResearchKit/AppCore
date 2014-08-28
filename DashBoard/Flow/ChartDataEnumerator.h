//
//  ChartEnumerator.h
//  Flow
//
//  Created by Karthik Keyan on 8/26/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChartDataEnumerator : NSEnumerator

@property (nonatomic, strong) NSNumber *min;
@property (nonatomic, strong) NSNumber *max;

- (BOOL) hasNextObject;

@end


@interface NSArray (ChartDataEnumerator)

- (ChartDataEnumerator *) chartEnumerator;

- (ChartDataEnumerator *) reverseChartEnumerator;

@end
