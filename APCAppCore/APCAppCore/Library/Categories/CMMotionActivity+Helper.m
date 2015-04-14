// 
//  CMMotionActivity+Helper.m 
//  APCAppCore 
// 
// Copyright (c) 2015, Apple Inc. All rights reserved. 
// 
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
// 
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
// 
// 2.  Redistributions in binary form must reproduce the above copyright notice, 
// this list of conditions and the following disclaimer in the documentation and/or 
// other materials provided with the distribution. 
// 
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors 
// may be used to endorse or promote products derived from this software without 
// specific prior written permission. No license is granted to the trademarks of 
// the copyright holders even if such marks are included in this software. 
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE 
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
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
