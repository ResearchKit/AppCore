//
//  APCDataVerificationClient_PersonalComputerIPAddresses.h
//  AppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//


/*
 Only allow this file to exist in the compiled code if
 we're diagnosting stuff, in-house.  For documentation,
 see:

 https://ymedialabs.atlassian.net/wiki/display/APPLE/How+to+see+the+data+we+send+to+Sage
 */
// ---------------------------------------------------------
#ifdef USE_DATA_VERIFICATION_CLIENT
// ---------------------------------------------------------



/**
 To make this app work with the DataVerificationServer,
 uncomment the entry for the computer where the server
 is running.  If you're using the Simulator, uncomment
 the "localhost" line (127.0.0.1).  Please set this back
 to "localhost" before committing to Git.

 This is safe becase the surrounding #define means
 this code will never ship in production.  The #defined
 item is triggered by a special Xcode Scheme.

 This is set up so you can easily type command-"/" to
 comment or uncomment certain lines.
 */

//	static NSString * const DATA_VERIFICATION_SERVER_IP_ADDRESS = @"10.5.28.84";	// Ron's Mac
	static NSString * const DATA_VERIFICATION_SERVER_IP_ADDRESS = @"127.0.0.1";		// "localhost" - if you're using the Simulator




// ---------------------------------------------------------
#endif  // USE_DATA_VERIFICATION_CLIENT
// ---------------------------------------------------------
