//
//  SBBErrors.h
//  SBBErrors
//
//  Created by Dhanush Balachandran on 8/15/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

//Error Codes
#define SBB_ERROR_DOMAIN @"org.sagebase.error_domain"
#define SBB_ORIGINAL_ERROR_KEY @"SBBOriginalErrorKey"

typedef NS_ENUM(NSInteger, SBBErrorCodes)
{
    kSBBUnknownError = -1,
    kSBBInternetNotConnected = -1000,
    kSBBServerNotReachable = -1001,
    kSBBServerUnderMaintenance = -1002,
    kSBBServerNotAuthenticated = -1003,
    kSBBServerPreconditionNotMet = -1004,
    kSBBNoCredentialsAvailable = -1005,
  
    kSBBNotAFileURL = -1100,
    kSBBObjectNotExpectedClass = -1101
};
