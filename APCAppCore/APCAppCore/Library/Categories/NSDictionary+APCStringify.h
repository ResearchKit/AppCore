//
//  NSDictionary+APCStringify.h
//  APCAppCore
//
//  Created by Justin Warmkessel on 4/20/15.
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (APCStringify)

+ (NSString*) convertDictionary:(NSDictionary *)dict ToStringWithReturningError: (NSError * __autoreleasing *) errorToReturn;

@end
