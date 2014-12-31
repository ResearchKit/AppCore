//
//  SBBGuidCreatedOnVersionHolder+APCAdditions.m
//  APCAppCore
//
//  Copyright (c) 2014 Apple, Inc. All rights reserved.
//

#import "SBBGuidCreatedOnVersionHolder+APCAdditions.h"

@implementation SBBGuidCreatedOnVersionHolder (APCAdditions)

- (NSString*) uniqueID
{
    NSString * retValue;
    if (self.version != nil) {
        retValue = [NSString stringWithFormat:@"%@-%@-%@", self.guid, self.createdOn, self.version];
    }
    else if (self.versionValue > 0)
    {
        retValue = [NSString stringWithFormat:@"%@-%@-%lld", self.guid, self.createdOn, self.versionValue];
    }
    else
    {
        retValue = [NSString stringWithFormat:@"%@-%@", self.guid, self.createdOn];
    }
    return retValue;
}

@end
