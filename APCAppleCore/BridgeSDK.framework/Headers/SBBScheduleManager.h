//
//  SBBScheduleManager.h
//  BridgeSDK
//
//  Created by Erin Mounts on 10/24/14.
//  Copyright (c) 2014 Sage Bionetworks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBBBridgeAPIManager.h"

/*!
 Completion block called when retrieving user schedules from the API.
 
 @param schedulesList By default, an SBBResourceList object, unless the ResourceList type has been mapped in SBBObjectManager setupMappingForType:toClass:fieldToPropertyMappings:. The item property (or whatever it was mapped to) contains an NSArray of SBBSchedule objects and the total (or mapped-to) property contains an NSNumber indicating how many Schedules were retrieved--again, unless the Schedule type has been mapped to a different class.
 @param error       An error that occurred during execution of the method for which this is a completion block, or nil.
 */
typedef void (^SBBScheduleManagerGetCompletionBlock)(id schedulesList, NSError *error);

/*!
 This protocol defines the interface to the SBBScheduleManager's non-constructor, non-initializer methods. The interface is
 abstracted out for use in mock objects for testing, and to allow selecting among multiple implementations at runtime.
 */
@protocol SBBScheduleManagerProtocol <SBBBridgeAPIManagerProtocol>

/*!
 Fetch the list of Schedules for the user from the Bridge API.
 
 @param completion An SBBScheduleManagerGetCompletionBlock to be called upon completion.
 
 @return An NSURLSessionDataTask object so you can cancel or suspend/resume the request.
 */
- (NSURLSessionDataTask *)getSchedulesWithCompletion:(SBBScheduleManagerGetCompletionBlock)completion;

@end


/*!
 This class handles communication with the Bridge Schedule API.
 */
@interface SBBScheduleManager : SBBBridgeAPIManager<SBBComponent, SBBScheduleManagerProtocol>

@end
