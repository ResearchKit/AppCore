//
//  NSDictionary+APCStringify.m
//  APCAppCore
//
//  Created by Justin Warmkessel on 4/20/15.
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "NSDictionary+APCStringify.h"

@implementation NSDictionary (APCStringify)

+ (NSString*) convertDictionary:(NSDictionary *)dict ToStringWithReturningError: (NSError * __autoreleasing *) errorToReturn
{
    NSString* stringRepresentation = @"";
    
    if (dict != nil)
    {
        NSError*    error       = nil;
        NSData*     jsonData    = [NSJSONSerialization dataWithJSONObject:dict
                                                                  options:0
                                                                    error:&error];
        
        // Something broke.  Return the provided error, if requested.
        if (errorToReturn != nil)
        {
            *errorToReturn = error;
        }
        
        stringRepresentation =  [[NSString alloc] initWithData:jsonData
                                                      encoding:NSUTF8StringEncoding];
    }
    
    return !errorToReturn ? stringRepresentation : @"";
}

@end
