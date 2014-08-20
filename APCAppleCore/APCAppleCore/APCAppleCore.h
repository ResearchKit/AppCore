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
#import "APCNetworkManager.h"

//Error Codes
#define APC_ERROR_DOMAIN @"com.ymedialabs.network_error_domain"
enum
{
    kAPCUnknownError = -1,
    kAPCInternetNotConnected = -1000,
    kAPCServerNotReachable = -1001,
    kAPCServerUnderMaintenance = -1002
};

#endif
