//
//  APCAppleCore.h
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 8/15/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef _APCAPPLECORE_
    #define _APCAPPLECORE_

//Headers
#import "APCAppDelegate.h"
#import "APCNetworkManager.h"
#import "APCSageNetworkManager.h"
#import "APCDataSubstrate.h"

//Categories
#import "NSError+APCAdditions.h"

//Error Codes
#define APC_ERROR_DOMAIN @"com.ymedialabs.network_error_domain"
#define APC_ORIGINAL_ERROR_KEY @"APCOriginalErrorKey"

typedef NS_ENUM(NSInteger, APCNetworkErrorCodes)
{
    kAPCUnknownError = -1,
    kAPCInternetNotConnected = -1000,
    kAPCServerNotReachable = -1001,
    kAPCServerUnderMaintenance = -1002,
    kAPCServerNotAuthenticated = -1003,
    kAPCServerPreconditionNotMet = -1004
};

#endif
