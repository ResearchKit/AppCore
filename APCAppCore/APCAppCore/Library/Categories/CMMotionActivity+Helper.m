//
//  CMMotionActivity+Helper.m
//  AppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "CMMotionActivity+Helper.h"
#import "NSDate+Helper.h"

typedef enum : NSUInteger {
    APCCMMotionActivityTypeUnknown = 0,
    APCCMMotionActivityTypeStationary,
    APCCMMotionActivityTypeWalking,
    APCCMMotionActivityTypeRunning,
    APCCMMotionActivityTypeAutomotive,
    APCCMMotionActivityTypeCycling,
} APCCMMotionActivityType;


@implementation CMMotionActivity (Helper)

+ (NSArray *) csvColumnNames
{
    NSMutableArray *names = [NSMutableArray new];

    /*
     Keep these in the same order as the "column values" entries below.
     */
    return @[@"dateAndTime",
             @"activityTypeName",
             @"activityTypeValue",
             @"confidenceName",
             @"confidenceRaw",
             @"confidencePercent"
             ];

    return names;
}

- (NSArray *) csvColumnValues
{
    NSString *dateStamp = self.startDate == nil ? @"unknown" : self.startDate.toStringInISO8601Format;
    NSString *activityTypeName = self.activityTypeName;
    APCCMMotionActivityType activityType = self.activityType;
    NSString *confidenceName = self.confidenceName;
    CMMotionActivityConfidence rawConfidence = self.confidence;
    NSString *confidencePercentAsString = self.confidencePercentAsString;

    /*
     Keep these in the same order as the "column names" entries above.
     */
    NSArray *values = @[dateStamp,
                        activityTypeName,
                        @(activityType),
                        confidenceName,
                        @(rawConfidence),
                        confidencePercentAsString
                        ];

    return values;
}

- (NSString *) confidenceName
{
    NSString *name = (self.confidence == CMMotionActivityConfidenceHigh ? @"high" :
                      self.confidence == CMMotionActivityConfidenceMedium ? @"medium" :
                      @"low");

    return name;
}

- (float) confidencePercent
{
    float confidence = (self.confidence == CMMotionActivityConfidenceHigh ? 1 :
                        self.confidence == CMMotionActivityConfidenceMedium ? 0.5 :
                        0);

    return confidence;
}

- (NSString *) confidencePercentAsString
{
    NSString *percent = [NSString stringWithFormat: @"%3.2f", self.confidencePercent];

    return percent;
}

- (APCCMMotionActivityType) activityType
{
    APCCMMotionActivityType type = (self.stationary ? APCCMMotionActivityTypeStationary :
                                    self.walking    ? APCCMMotionActivityTypeWalking :
                                    self.running    ? APCCMMotionActivityTypeRunning :
                                    self.automotive ? APCCMMotionActivityTypeAutomotive :
                                    self.cycling    ? APCCMMotionActivityTypeCycling :
                                    APCCMMotionActivityTypeUnknown);

    return type;
}

- (NSString *) activityTypeName
{
    NSString *name = nil;

    switch (self.activityType)
    {
        case APCCMMotionActivityTypeStationary : name = @"stationary";  break;
        case APCCMMotionActivityTypeWalking    : name = @"walking";     break;
        case APCCMMotionActivityTypeRunning    : name = @"running";     break;
        case APCCMMotionActivityTypeAutomotive : name = @"automotive";  break;
        case APCCMMotionActivityTypeCycling    : name = @"cycling";     break;

        default:
        case APCCMMotionActivityTypeUnknown    : name = @"unknown";     break;
    }

    return name;
}

@end
