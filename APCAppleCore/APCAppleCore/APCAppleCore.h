//
//  APCAppleCore.h
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 9/22/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for APCAppleCore.
FOUNDATION_EXPORT double APCAppleCoreVersionNumber;

//! Project version string for APCAppleCore.
FOUNDATION_EXPORT const unsigned char APCAppleCoreVersionString[];

//Headers
#import <APCAppleCore/APCAppDelegate.h>
#import <APCAppleCore/APCNetworkManager.h>
#import <APCAppleCore/APCSageNetworkManager.h>
#import <APCAppleCore/APCDataSubstrate.h>
#import <APCAppleCore/APCDataSubstrate+ResearchKit.h>
#import <APCAppleCore/APCDataSubstrate+CoreData.h>
#import <APCAppleCore/APCModel.h>
#import <APCAppleCore/APCDataMonitor.h>
#import <APCAppleCore/APCScheduler.h>

//UI
#import <APCAppleCore/APCSignInViewController.h>
#import <APCAppleCore/APCUserInfoCell.h>

//Categories
#import <APCAppleCore/NSError+APCAdditions.h>
#import <APCAppleCore/NSBundle+Helper.h>

//Error Codes
static NSString *const APC_ERROR_DOMAIN = @"com.ymedialabs.error_domain";
static NSString *const APC_ORIGINAL_ERROR_KEY = @"APCOriginalErrorKey";

typedef NS_ENUM(NSInteger, APCNetworkErrorCodes)
{
    kAPCUnknownError = -1,
    kAPCInternetNotConnected = -1000,
    kAPCServerNotReachable = -1001,
    kAPCServerUnderMaintenance = -1002,
    kAPCServerNotAuthenticated = -1003,
    kAPCServerPreconditionNotMet = -1004
};

static NSString *const APCUserLoginNotification     = @"APCUserLoginNotification";
static NSString *const APCUserLogOutNotification  = @"APCUserLogOutNotification";