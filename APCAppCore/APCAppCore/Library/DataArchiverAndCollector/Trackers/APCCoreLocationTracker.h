// 
//  APCPassiveLocationTracking.h 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "APCGenericDataTracker.h"

/**
 Used for passive location tracking. PausesLocationUpdatesAutomatically property is set to YES. Core Location pauses
 updates (and powers down the location hardware) whenever it makes sense to do so, such as when the user is 
 unlikely to be moving away. The – allowDeferredLocationUpdatesUntilTraveled:timeout: from CLLocationManager is 
 used to defer the delivery of updates until specified amount of time has passed: this is set at the time of initialization.
 **/

typedef  enum  _APCPassiveLocationTrackingHomeLocation
{
    APCPassiveLocationTrackingHomeLocationAvailable,
    APCPassiveLocationTrackingHomeLocationUnavailable
}  APCPassiveLocationTrackingHomeLocation;

@protocol APCLocationTrackingHeartbeatDelegate;

@interface APCCoreLocationTracker : APCGenericDataTracker <CLLocationManagerDelegate>


/**
 *  @brief Designated initializer
 *
 *  @param timeout      The amount of time (in seconds) from the current time that must pass before
 *                      event delivery resumes. To specify an unlimited amount of time, pass the
 *                      CLTimeIntervalMax constant
 *
 *  @return instancetype
 */
- (instancetype)initWithDeferredUpdatesTimeout:(NSTimeInterval)anUpdateTimeout andHomeLocationStatus:(APCPassiveLocationTrackingHomeLocation)aHomeLocationStatus;

/**
 *  @brief Starts updating location.
 *
 */
- (void)start;

/**
 *  @brief Stop updating location
 *
 */
- (void)stop;

/**
 *  @brief Retrieves all the geocoordinates from the log file.
 *
 *  @return A NSDictionary of geocoordinates
 */
- (NSDictionary *)retreieveLocationMarkersFromLog;

/**
 *  Delegate conforms to APCLocationTrackingHeartbeatDelegate.
 *
 */
@property (weak, nonatomic) id <APCLocationTrackingHeartbeatDelegate> delegate;

@end


/*********************************************************************************/
//Protocol
/*********************************************************************************/
@protocol APCLocationTrackingHeartbeatDelegate <NSObject>


@optional

/*********************************************************************************/
//Location Delegate Methods

/**
 * @brief Location has failed to update.
 */
- (void)passiveLocationTracking:(APCCoreLocationTracker *)parameters didFailToUpdateLocationWithError:(NSError *)error;

/**
 * @brief Location updates did pause.
 */
- (void)passiveLocationTracking:(APCCoreLocationTracker *)parameters didPauseLocationTracking:(CLLocationManager *)manager;

/**
 * @brief Location updates did resume.
 */
- (void)passiveLocationTracking:(APCCoreLocationTracker *)parameters didResumeLocationTracking:(CLLocationManager *)manager;

/*********************************************************************************/
//Logging Delegate Methods

/**
 * @brief _self_ failed to update the log.
 */
- (void)passiveLocationTracking:(APCCoreLocationTracker *)parameters didFailToUpdateLogWithError:(NSError *)error;

/**
 * @brief _self_ failed to delete log file.
 */
- (void)passiveLocationTracking:(APCCoreLocationTracker *)parameters didFailToDeleteLogWithError:(NSError *)error;

/**
 * @brief The total size of files that are not marked uploaded, has reached a threshold.
 */
- (void)passiveLocationTracking:(APCCoreLocationTracker *)parameters didFailToUploadLog:(NSError *)error;

/**
 * @brief Finished saving log.
 */
- (void)passiveLocationTracking:(APCCoreLocationTracker *)parameters didFinishSavingLog:(NSURL *)fileURL;


@end
