//
//  APCConstants.h
//  APCAppleCore
//
//  Created by Ramsundar Shandilya on 11/13/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#ifndef APCAppleCore_APCConstants_h
#define APCAppleCore_APCConstants_h

typedef NS_ENUM(NSUInteger, APCSignUpPermissionsType) {
    kSignUpPermissionsTypeHealthKit,
    kSignUpPermissionsTypeLocation,
    kSignUpPermissionsTypePushNotifications,
    kSignUpPermissionsTypeCoremotion,
};

typedef NS_ENUM(NSUInteger, APCDashboardMessageType) {
    kAPCDashboardMessageTypeAlert,
    kAPCDashboardMessageTypeInsight,
};

typedef NS_ENUM(NSUInteger, APCDashboardGraphType) {
    kAPCDashboardGraphTypeLine,
    kAPCDashboardGraphTypePie,
    kAPCDashboardGraphTypeTimeline,
};

#endif
