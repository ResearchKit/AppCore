// 
//  APCPassiveLocationTracking.h 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "APCDataTracker.h"

typedef  enum  _APCPassiveLocationTrackingHomeLocation
{
    APCPassiveLocationTrackingHomeLocationAvailable,
    APCPassiveLocationTrackingHomeLocationUnavailable
}  APCPassiveLocationTrackingHomeLocation;

@interface APCCoreLocationTracker : APCDataTracker

- (instancetype)initWithIdentifier: (NSString*) identifier deferredUpdatesTimeout:(NSTimeInterval)anUpdateTimeout andHomeLocationStatus:(APCPassiveLocationTrackingHomeLocation)aHomeLocationStatus;

@end

