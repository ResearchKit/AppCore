//
//  APCModel.h
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 8/28/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#ifndef APCAppleCore_APCModel_h
#define APCAppleCore_APCModel_h

#import "NSManagedObject+APCHelper.h"

/*********************************************************************************/
#pragma mark - Memory Only Objects
/*********************************************************************************/
#import "APCUser+HealthKit.h"
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
#import "APCConsentResult+AddOn.h"
#import "APCDataResult+AddOn.h"
#import "APCFileResult+AddOn.h"
#import "APCQuestionResult+AddOn.h"
#import "APCSurveyResult+AddOn.h"

#import "APCStoredUserData.h"

#endif
