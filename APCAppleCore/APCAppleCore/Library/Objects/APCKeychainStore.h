//
//  APCKeychainStore.h
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 10/2/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APCKeychainStore : NSObject

+ (NSString *)stringForKey:(NSString *)key;
+ (BOOL)setString:(NSString *)value forKey:(NSString *)key;
+ (void) removeValueForKey: (NSString*) key;
+ (void) resetKeyChain;

@end
