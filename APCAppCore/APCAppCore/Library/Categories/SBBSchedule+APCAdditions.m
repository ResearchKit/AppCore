// 
//  SBBSchedule+APCAdditions.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "SBBSchedule+APCAdditions.h"

const int kIDPosition = 4;

@implementation SBBSchedule (APCAdditions)

- (NSString *)taskID
{
    if ([self.activityType isEqualToString:@"survey"]) {
        NSArray * pathComponents = [[NSURL URLWithString:self.activityRef] pathComponents];
        return [pathComponents[kIDPosition] stringByAppendingFormat:@"-%@", [pathComponents lastObject]];
    }
    else
    {
        return self.activityRef;
    }

}

@end
