//
//  ChartDataService.m
//  Flow
//
//  Created by Karthik Keyan on 8/25/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "ChartDataService.h"

@interface ChartDataService ()

@property (nonatomic, strong) NSMutableIndexSet *subscribedServices;

@end

@implementation ChartDataService

- (instancetype)init
{
    self = [super init];
    if (self) {
        _subscribedServices = [NSMutableIndexSet new];
    }
    return self;
}

#pragma mark - Public Methods

- (void) subscribeToServiceType:(ChartDataServiceType)serviceType {
    if (![self.subscribedServices containsIndex:serviceType]) {
        [self.subscribedServices addIndex:serviceType];
    }
}

- (void) unsubscribeToServiceType:(ChartDataServiceType)serviceType {
    if ([self.subscribedServices containsIndex:serviceType]) {
        [self.subscribedServices removeIndex:serviceType];
    }
}

- (NSArray *) allValuesForServiceType:(ChartDataServiceType)serviceType {
    return nil;
}

- (void) didReceiveNewValues:(NSArray *)newValues {
    newValues = @[@(8), @(9), @(10), @(11), @(12)];
    
    [self.delegate chartDataService:self didReceiveNewValues:newValues.chartEnumerator forServiceType:ChartDataServiceTypeHeartRate];
}

@end
