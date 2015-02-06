//
//  APCUtilities.m
//  AppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCUtilities.h"
#import "APCDeviceHardware.h"


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


@implementation APCUtilities

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

		_appName = ([self cleanString: bundleInfo [@"CFBundleDisplayName"]] ?:		// source: info.plist > Bundle Display Name
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

@end
