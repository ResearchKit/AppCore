// 
//  APCKeychainStore.m 
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
 
#import "APCKeychainStore.h"
#import "APCLog.h"

static NSString *_defaultService;

@implementation APCKeychainStore

/*********************************************************************************/
#pragma mark - Public Methods
/*********************************************************************************/
+ (BOOL)setString:(NSString *)value forKey:(NSString *)key
{
    NSData *data = [value dataUsingEncoding:NSUTF8StringEncoding];
    return [self setData:data forKey:key service:[self defaultService] accessGroup:nil];
}

+ (NSString *)stringForKey:(NSString *)key
{
    NSData *data = [self dataForKey:key service:[self defaultService] accessGroup:nil];
    return data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : nil;
}

+ (void)removeValueForKey:(NSString *)key
{
    [self removeItemForKey:key service:[self defaultService] accessGroup:nil];
}

+(void)resetKeyChain
{
    [self removeAllItemsForService:[self defaultService] accessGroup:nil];
}

/*********************************************************************************/
#pragma mark - Private Methods
/*********************************************************************************/

+ (NSString *)defaultService
{
    if (!_defaultService) {
        _defaultService = [[NSBundle mainBundle] bundleIdentifier];
    }
    
    return _defaultService;
}


+ (NSData *) dataForKey: (NSString *) key
                service: (NSString *) service
            accessGroup: (NSString *) __unused accessGroup
{
    NSData * ret = nil;
    if (key) {
        if (!service) {
            service = [self defaultService];
        }
        
        NSMutableDictionary *query = [[NSMutableDictionary alloc] init];
        [query setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
        [query setObject:(__bridge id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
        [query setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
        [query setObject:service forKey:(__bridge id)kSecAttrService];
        [query setObject:key forKey:(__bridge id)kSecAttrAccount];
#if !TARGET_IPHONE_SIMULATOR && defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
        if (accessGroup) {
            [query setObject:accessGroup forKey:(__bridge id)kSecAttrAccessGroup];
        }
#endif
        
        CFTypeRef data = nil;
        OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &data);
        if (status != errSecSuccess) {
            APCLogDebug(@"SecItemCopyMatching query failed with error code: %lii", status);
            return nil;
        }
        
        ret = [NSData dataWithData:(__bridge NSData *)data];
        if (data) {
            CFRelease(data);
        }
    }
    return ret;
}

+ (BOOL)setData:(NSData *)data forKey:(NSString *)key service:(NSString *)service accessGroup:(NSString *)accessGroup
{
    BOOL retValue = NO;
    if (key) {
        if (!service) {
            service = [self defaultService];
        }
        
        NSMutableDictionary *query = [[NSMutableDictionary alloc] init];
        [query setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
        [query setObject:service forKey:(__bridge id)kSecAttrService];
        [query setObject:key forKey:(__bridge id)kSecAttrGeneric];
        [query setObject:key forKey:(__bridge id)kSecAttrAccount];
#if !TARGET_IPHONE_SIMULATOR && defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
        if (accessGroup) {
            [query setObject:accessGroup forKey:(__bridge id)kSecAttrAccessGroup];
        }
#endif
        
        OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, NULL);
        if (status == errSecSuccess) {
            if (data) {
                NSMutableDictionary *attributesToUpdate = [[NSMutableDictionary alloc] init];
                [attributesToUpdate setObject:data forKey:(__bridge id)kSecValueData];
                
                status = SecItemUpdate((__bridge CFDictionaryRef)query, (__bridge CFDictionaryRef)attributesToUpdate);
                if (status != errSecSuccess) {
                    goto errReturn;
                }
            } else {
                [self removeItemForKey:key service:service accessGroup:accessGroup];
            }
        } else if (status == errSecItemNotFound) {
            NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
            [attributes setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
            [attributes setObject:service forKey:(__bridge id)kSecAttrService];
            [attributes setObject:key forKey:(__bridge id)kSecAttrGeneric];
            [attributes setObject:key forKey:(__bridge id)kSecAttrAccount];
#if TARGET_OS_IPHONE || (defined(MAC_OS_X_VERSION_10_9) && MAC_OS_X_VERSION_MIN_REQUIRED >= MAC_OS_X_VERSION_10_9)
            [attributes setObject:(__bridge id)kSecAttrAccessibleAfterFirstUnlock forKey:(__bridge id)kSecAttrAccessible];
#endif
            [attributes setObject:data forKey:(__bridge id)kSecValueData];
#if !TARGET_IPHONE_SIMULATOR && defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
            if (accessGroup) {
                [attributes setObject:accessGroup forKey:(__bridge id)kSecAttrAccessGroup];
            }
#endif
            
            status = SecItemAdd((__bridge CFDictionaryRef)attributes, NULL);
            if (status != errSecSuccess) {
                goto errReturn;
            }
        }
        else
        {
            goto errReturn;
        }
        retValue = YES;
    }
    
errReturn:
    return retValue;
}

+ (BOOL) removeItemForKey: (NSString *) key
                  service: (NSString *) service
              accessGroup: (NSString *) __unused accessGroup
{
    BOOL retValue = NO;
    if (key) {
        if (!service) {
            service = [self defaultService];
        }
        
        NSMutableDictionary *itemToDelete = [[NSMutableDictionary alloc] init];
        [itemToDelete setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
        [itemToDelete setObject:service forKey:(__bridge id)kSecAttrService];
        [itemToDelete setObject:key forKey:(__bridge id)kSecAttrGeneric];
        [itemToDelete setObject:key forKey:(__bridge id)kSecAttrAccount];
#if !TARGET_IPHONE_SIMULATOR && defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
        if (accessGroup) {
            [itemToDelete setObject:accessGroup forKey:(__bridge id)kSecAttrAccessGroup];
        }
#endif
        
        OSStatus status = SecItemDelete((__bridge CFDictionaryRef)itemToDelete);
        if (status != errSecSuccess && status != errSecItemNotFound) {
            retValue = NO;
        }
        else
        {
            retValue = YES;
        }
    }
    
    return retValue;
}

+ (BOOL)removeAllItemsForService:(NSString *)service accessGroup:(NSString *)accessGroup
{
    NSArray *items = [self itemsForService:service accessGroup:accessGroup];
    BOOL retValue = NO;
    for (NSDictionary *item in items) {
        NSMutableDictionary *itemToDelete = [[NSMutableDictionary alloc] initWithDictionary:item];
        [itemToDelete setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
        
        OSStatus status = SecItemDelete((__bridge CFDictionaryRef)itemToDelete);
        if (status != errSecSuccess) {
            retValue = NO;
        }
        else
        {
            retValue = YES;
        }
    }
    
    return retValue;
}

+ (NSArray *) itemsForService: (NSString *) service
                  accessGroup: (NSString *) __unused accessGroup
{
    if (!service) {
        service = [self defaultService];
    }
    
    NSMutableDictionary *query = [[NSMutableDictionary alloc] init];
    [query setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    [query setObject:(id)kCFBooleanTrue forKey:(__bridge id)kSecReturnAttributes];
    [query setObject:(id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
    [query setObject:(__bridge id)kSecMatchLimitAll forKey:(__bridge id)kSecMatchLimit];
    [query setObject:service forKey:(__bridge id)kSecAttrService];
#if !TARGET_IPHONE_SIMULATOR && defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
    if (accessGroup) {
        [query setObject:accessGroup forKey:(__bridge id)kSecAttrAccessGroup];
    }
#endif
    
    CFTypeRef result = nil;
    NSArray *returnValue = nil;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
    if (status == errSecSuccess || status == errSecItemNotFound) {
        returnValue =  (__bridge NSArray *)(result);
    } else {
        returnValue = nil;
    }
    if(result)
    {
         CFBridgingRelease(result);
    }
   
    return returnValue;
}


@end
