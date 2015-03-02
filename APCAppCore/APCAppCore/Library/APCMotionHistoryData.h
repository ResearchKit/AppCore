//
//  APCMotionHistoryData.h
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ActivityType)
{
    ActivityTypeStationary = 1,
    ActivityTypeWalking,
    ActivityTypeRunning,
    ActivityTypeAutomotive,
    ActivityTypeCycling,
    ActivityTypeUnknown,
    ActivityTypeSleeping,
    ActivityTypeLight,
    ActivityTypeModerate,
    ActivityTypeSedentary
    
};

@interface APCMotionHistoryData : NSObject

@property (nonatomic) ActivityType activityType;
@property (nonatomic) NSTimeInterval timeInterval;


- (id)initWithActivityType:(ActivityType)activityType andTimeInterval:(NSTimeInterval)timeInterval;

@end
