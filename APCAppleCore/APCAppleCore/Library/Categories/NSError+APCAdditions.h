//
//  NSError+APCAdditions.h
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 8/22/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError (APCAdditions)

+ (NSError*) generateAPCErrorForNSURLError:(NSError *)urlError isInternetConnected:(BOOL)internetConnected isServerReachable:(BOOL)isServerReachable;
+ (NSError*) generateAPCErrorForHTTPResponse: (NSHTTPURLResponse*) response;
+ (NSError*) APCNotAuthenticatedError;

@end
