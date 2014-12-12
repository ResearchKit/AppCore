//
//  APCLog_Settings.h
//  AppCore
//
//  Copyright (c) 2014 Apple Inc. All rights reserved.
//


/*
 This file contains common logging settings, so you can
 adjust them without having to wade through the code
 to find them.
 */



// ---------------------------------------------------------
#pragma mark - Flurry:  API keys
// ---------------------------------------------------------

/**
 Comment out the lines which don't represent your app.
 */
static NSString *FLURRY_API_KEY = @"N6Y52H6HPN6ZJ9DGN2JV";	// App "Test," developer personal account
//static NSString *FLURRY_API_KEY = @"PQKTW6488576S4PXN6BV";	// App "Asthma," code name "Air"



// ---------------------------------------------------------
#pragma mark - Flurry:  Enable/Disable
// ---------------------------------------------------------

/**
 Enable or disable Flurry.  Flurry is called when
 the app launches, from:

	-[APCAppDelegate application:didFinishLaunchingWithOptions:]

 And several of the logging methods/macros call it.
 */
#define APCLOG_USE_FLURRY  YES
//#define APCLOG_USE_FLURRY  NO



// ---------------------------------------------------------
#pragma mark - Print Statements:  enable/disable
// ---------------------------------------------------------

/**
 Enables or disables all logging, according to the
 global DEBUG setting (i.e., whether we're in a
 "debug" or "release" configuration, as defined
 in the current Xcode "scheme").
 */
#ifdef DEBUG
	#define APCLOG_IS_DEBUG_DEFINED YES
#else
	#define APCLOG_IS_DEBUG_DEFINED NO
#endif


/**
 Doesn't seem to work in the test harness.  Works fine in the
 running applications, though.
 */
#define APCLOG_PRINT_LOGGING_STATEMENTS  YES	// APCLOG_IS_DEBUG_DEFINED


