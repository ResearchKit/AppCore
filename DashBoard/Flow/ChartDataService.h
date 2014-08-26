//
//  ChartDataService.h
//  Flow
//
//  Created by Karthik Keyan on 8/25/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ChartDataServiceType) {
    ChartDataServiceTypeHeartRate = 0,
    ChartDataServiceTypeSteps,
    ChartDataServiceTypeBloodSugar
};

@protocol ChartDataServiceDelegate;

@interface ChartDataService : NSObject

@property (nonatomic, weak) id<ChartDataServiceDelegate> delegate;

- (void) subscribeToServiceType:(ChartDataServiceType)serviceType;

- (void) unsubscribeToServiceType:(ChartDataServiceType)serviceType;

- (NSArray *) allValuesForServiceType:(ChartDataServiceType)serviceType;

@end


@protocol ChartDataServiceDelegate <NSObject>

@optional
- (void) chartDataService:(ChartDataService *)service didReceiveNewValues:(NSEnumerator *)enumerator forServiceType:(ChartDataServiceType)serviceType;

@end

