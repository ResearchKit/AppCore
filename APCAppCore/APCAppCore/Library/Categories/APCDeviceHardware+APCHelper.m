//
//  APCDeviceHardware+APCHelper.h
//  AppCore
//
//  Copyright (c) 2014 Apple Inc. All rights reserved.
//

#import "APCDeviceHardware+APCHelper.h"

@implementation APCDeviceHardware (APCHelper)

+ (BOOL)isiPhone5SOrNewer
{
    NSString *platform = [APCDeviceHardware platform];
    
    BOOL value = NO;
    
    if ([platform hasPrefix:@"iPod"] || [platform hasPrefix:@"iPad"]) {
        value = NO;
        
    } else if ([platform hasPrefix:@"iPhone"]) {
        
        NSString *prefix = @"iPhone";
        NSString *generation = [platform substringFromIndex:prefix.length];
        
        NSInteger generationNumber = [[[generation componentsSeparatedByString:@","] firstObject] integerValue];
        
        if (generationNumber >= 6) {
            value = YES;
        }
        
    } else {
        //Simulator
        value = YES;
    }
    
    return value;
}
@end
