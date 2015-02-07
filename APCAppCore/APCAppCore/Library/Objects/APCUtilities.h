//
//  APCUtilities.h
//  AppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APCUtilities : NSObject

/**
 Human-readable name of the app, on the phone's
 desktop (the Springboard).
 
 We're still evolving how to figure this out.
 We have 9 different experiments in here.  So far,
 at least one of them works in each app.
 */
+ (NSString *) appName;

/**
 Version number and build number.
 */
+ (NSString *) appVersion;

/**
 "Simulator," "iPhone 4GS," etc.
 */
+ (NSString *) deviceDescription;

/**
 "Simulator," "iPhone 4GS," etc.

 Actually, this just returns +deviceDescription.  I'm providing this
 because, to me, "phone info" makes more sense, when you're hunting
 through these libraries for something useful, even though 
 "device description" is more accurate.
 */
+ (NSString *) phoneInfo;

/**
 Trims whitespace from someString and returns it.
 If the trimmed string has length 0, returns nil.
 This lets us do simplified "if" statements, evaluating
 the string for its "truth" value.
 
 Included in this file simply because I needed it for the
 other code in this file.  If we find a better home for it,
 please move it there.
 */
+ (NSString *) cleanString: (NSString *) someString;


@end
