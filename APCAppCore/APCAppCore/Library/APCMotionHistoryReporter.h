//
//  APCMotionHistoryReporter.h
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface APCMotionHistoryReporter : NSObject
{
    
}

+(APCMotionHistoryReporter *)sharedInstance;


-(void)startMotionCoProcessorDataFrom:(NSDate *)startDate andEndDate:(NSDate *)endDate andNumberOfDays:(NSInteger)numberOfDays;

-(BOOL)isDataReady;

-(NSArray*)retrieveMotionReport;

@end
