//
//  APCTimeRange.h
//  APCAppCore
//
//  Copyright (c) 2014 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APCTimeRange : NSObject

@property (nonatomic, strong) NSDate * startDate;
@property (nonatomic, strong) NSDate * endDate;

- (instancetype) initWithStartDate: (NSDate*) startDate endDate: (NSDate*) endDate;

@end
