//
//  APCLocationTrackingHeartbeat.h
//  APCAppleCore
//
//  Created by Justin Warmkessel on 9/24/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <ResearchKit/ResearchKit.h>

/**
 Used for passive location tracking. PausesLocationUpdatesAutomatically property is set to YES. Core Location pauses
 updates (and powers down the location hardware) whenever it makes sense to do so, such as when the user is 
 unlikely to be moving away. The – allowDeferredLocationUpdatesUntilTraveled:timeout: from CLLocationManager is 
 used to defer the delivery of updates until specified amount of time has passed: this is set at the time of initialization.
 **/

@protocol APCLocationTrackingHeartbeatDelegate;

@interface APCPassiveLocationTracking : NSObject <CLLocationManagerDelegate>


/**
 *  @brief Designated initializer
 *
 *  @param timeout      The amount of time (in seconds) from the current time that must pass before
 *                      event delivery resumes. To specify an unlimited amount of time, pass the
 *                      CLTimeIntervalMax constant
 *
 *  @return instancetype
 */
-(instancetype)initWithTimeInterval:(NSTimeInterval)timeout;


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
- (void)passiveLocationTracking:(APCPassiveLocationTracking *)parameters didFailToUpdateLocationWithError:(NSError *)error;

/**
 * @brief Location updates did pause.
 */
- (void)passiveLocationTracking:(APCPassiveLocationTracking *)parameters didPauseLocationTracking:(CLLocationManager *)manager;

/**
 * @brief Location updates did resume.
 */
- (void)passiveLocationTracking:(APCPassiveLocationTracking *)parameters didResumeLocationTracking:(CLLocationManager *)manager;

/*********************************************************************************/
//Logging Delegate Methods

/**
 * @brief _self_ failed to update the log.
 */
- (void)passiveLocationTracking:(APCPassiveLocationTracking *)parameters didFailToUpdateLogWithError:(NSError *)error;

/**
 * @brief _self_ failed to delete log file.
 */
- (void)passiveLocationTracking:(APCPassiveLocationTracking *)parameters didFailToDeleteLogWithError:(NSError *)error;

/**
 * @brief The total size of files that are not marked uploaded, has reached a threshold.
 */
- (void)passiveLocationTracking:(APCPassiveLocationTracking *)parameters didFailToUploadLog:(NSError *)error;

/**
 * @brief Finished saving log.
 */
- (void)passiveLocationTracking:(APCPassiveLocationTracking *)parameters didFinishSavingLog:(NSURL *)fileURL;


@end
