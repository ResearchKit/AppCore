//
//  APCModel.h
//  APCAppCore
//
//  Created by Dhanush Balachandran on 8/28/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#ifndef APCAppCore_APCModel_h
#define APCAppCore_APCModel_h

#import "NSManagedObject+APCHelper.h"

/*********************************************************************************/
#pragma mark - Memory Only Objects
/*********************************************************************************/
#import "APCUser+UserData.h"
#import "APCUser+Bridge.h"

/*********************************************************************************/
#pragma mark - Core Data Model Objects
/*********************************************************************************/
#import "APCTask+AddOn.h"
#import "APCTask+Bridge.h"
#import "APCSchedule+AddOn.h"
#import "APCScheduledTask+AddOn.h"
#import "APCDBStatus+AddOn.h"

//Results Cluster
#import "APCResult+AddOn.h"
#import "APCResult+Bridge.h"

#import "APCStoredUserData.h"

#endif
