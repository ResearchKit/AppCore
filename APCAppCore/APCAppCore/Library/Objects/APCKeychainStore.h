// 
//  APCKeychainStore.h 
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//
 
#import <Foundation/Foundation.h>

@interface APCKeychainStore : NSObject

+ (NSString *)stringForKey:(NSString *)key;
+ (BOOL)setString:(NSString *)value forKey:(NSString *)key;
+ (void) removeValueForKey: (NSString*) key;
+ (void) resetKeyChain;

@end
