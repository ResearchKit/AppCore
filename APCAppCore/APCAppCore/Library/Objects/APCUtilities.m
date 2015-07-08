// 
//  APCUtilities.m 
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
 
#import "APCUtilities.h"
#import "APCDeviceHardware.h"
#import "APCLog.h"
#import <sys/sysctl.h>

/**
 These are fixed per launch of the app.  They're also
 small.  So cache them -- partly because we're still figuring
 out how to find them (and having trouble in some apps).
 */
static NSString *_appName = nil;
static NSString *_appVersion = nil;
static NSString *_deviceDescription = nil;

static NSString * const APP_NAME_IF_CANT_DETECT		= @"CouldNotRetrieveAppName";
static NSString * const VERSION_IF_CANT_DETECT		= @"???";
static NSString * const BUILD_IF_CANT_DETECT		= @"???";
static NSString * const DEVICE_INFO_IF_CANT_DETECT	= @"CouldNotRetrieveDeviceInfo";
static NSString *       _realApplicationName = nil;


@implementation APCUtilities

+ (void) setRealApplicationName: (NSString *) realAppName
{
    _realApplicationName = realAppName;
}

+ (NSString *) deviceDescription
{
	if (_deviceDescription == nil)
	{
		_deviceDescription = [self cleanString: APCDeviceHardware.platformString] ?: DEVICE_INFO_IF_CANT_DETECT;
	}

	return _deviceDescription;
}

+ (NSString *) phoneInfo
{
	return self.deviceDescription;
}

+ (NSString *) appVersion
{
	if (_appVersion == nil)
	{
		NSString *version = [self cleanString: NSBundle.mainBundle.infoDictionary [@"CFBundleShortVersionString"]] ?: VERSION_IF_CANT_DETECT;
		NSString *build   = [self cleanString: NSBundle.mainBundle.infoDictionary [@"CFBundleVersion"]] ?: BUILD_IF_CANT_DETECT;
		
		_appVersion	= [NSString stringWithFormat: @"version %@, build %@", version, build];
	}

	return _appVersion;
}

+ (NSString *) appName
{
	if (_appName == nil)
	{
		NSBundle *mainBundle = [NSBundle mainBundle];
		NSDictionary *bundleInfo = mainBundle.infoDictionary;
		NSDictionary *localizedBundleInfo = mainBundle.localizedInfoDictionary;

		/*
		 How do we get the app name, officially?

		 Here are a bunch of attempts.  Some work in some of
		 our apps, and others don't.  I don't yet know why
		 the ones that work actually work.
		 
		 -----------------
		 ABOUT THIS SYNTAX
		 -----------------
		 The syntax below is a short way of writing 10 "if"
		 statements to evaluate a bunch of strings.  Each line
		 works like this (here's line 2 as an example):
		 -
		 -			[self cleanString: bundleInfo [@"CFBundleDisplayName"]] ?:
		 -			                   11111111111111111111111111111111111
		 -			 22222222222222222
		 -			                                                        3    <--- look
		 -			                                                         4   <---   here
		 -	1.	try to extract the string from somewhere
		 -	2.	clean it (trim, set to nil if empty)
		 -	3.	if it's non-nil and non-empty, use it
		 -	4.	otherwise, try the next line
		 */

        _appName = ([self cleanString: _realApplicationName] ?:
                    
                    [self cleanString: bundleInfo [@"CFBundleDisplayName"]] ?:		// source: info.plist > Bundle Display Name
					[self cleanString: bundleInfo [@"CFBundleName"]] ?:				// source: info.plist > Bundle Name
					[self cleanString: bundleInfo [@"CFBundleExecutable"]] ?:		// source: ?

					// Apple:  "please use this method, 'cuz it gets the localized version if one is available"
					[self cleanString: [mainBundle objectForInfoDictionaryKey: @"CFBundleDisplayName"]] ?:		// source: ?
					[self cleanString: [mainBundle objectForInfoDictionaryKey: @"CFBundleName"]] ?:				// source: ?
					[self cleanString: [mainBundle objectForInfoDictionaryKey: @"CFBundleExecutable"]] ?:		// source: ?

					[self cleanString: localizedBundleInfo [@"CFBundleDisplayName"]] ?:		// source: ?
					[self cleanString: localizedBundleInfo [@"CFBundleName"]] ?:			// source: ?
					[self cleanString: localizedBundleInfo [@"CFBundleExecutable"]] ?:		// source: ?

					APP_NAME_IF_CANT_DETECT);
	}

	return _appName;
}

+ (BOOL) isInDebuggingMode
{
    BOOL result = NO;

    #if DEBUG
        result = YES;
    #endif

    return result;
}

/**
 Trims whitespace from someString and returns it.
 If the trimmed string has length 0, returns nil.
 This lets us do simplified "if" statements, evaluating
 the string for its "truth" value.
 */
+ (NSString *) cleanString: (NSString *) someString
{
	NSString *result = [someString stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];

	if (result.length == 0)
	{
		result = nil;
	}

	return result;
}

+ (NSString *) pathToUserDocumentsFolder
{
    NSString *documentsFolder = (NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES)).firstObject;

    return documentsFolder;
}

+ (NSString *) pathToTemporaryDirectoryAddingUuid: (BOOL) shouldAddUuid
{
    NSString *tempDirectory = NSTemporaryDirectory ();

    if (shouldAddUuid)
    {
        NSString *uuid = [[NSUUID UUID] UUIDString];
        tempDirectory = [tempDirectory stringByAppendingPathComponent: uuid];
    }

    return tempDirectory;
}

+ (NSDate *) firstKnownFileAccessDate
{
    NSDate *result = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *applicationDocumentsDirectory = ([paths count] > 0) ? paths[0] : nil;
    NSFileManager*  fileManager = [NSFileManager defaultManager];
    NSString*       filePath    = [applicationDocumentsDirectory stringByAppendingPathComponent:@"db.sqlite"];
    
    if ([fileManager fileExistsAtPath:filePath])
    {
        NSError*        error       = nil;
        NSDictionary*   attributes  = [fileManager attributesOfItemAtPath:filePath error:&error];
        
        if (error)
        {
            APCLogError2(error);
        }
        else
        {
            result = [attributes fileCreationDate];
        }
    }

    return result;
}

time_t kernelBootTime()
{
    struct timeval bootTime;
    
    time_t bootTimeSeconds = -1;
    int    mib[2] = { CTL_KERN, KERN_BOOTTIME };
    size_t size   = sizeof(bootTime);
    
    if (sysctl(mib, 2, &bootTime, &size, NULL, 0) != -1 && bootTime.tv_sec != 0)
    {
        bootTimeSeconds = bootTime.tv_sec;
    }
    
    return bootTimeSeconds;
}

time_t uptime()
{
    time_t bootTime = kernelBootTime();
    time_t upTime   = -1;
    
    if (bootTime != -1)
    {
        time_t  now;
        
        time(&now);
        upTime = now - bootTime;
    }
    
    return upTime;
}

@end
