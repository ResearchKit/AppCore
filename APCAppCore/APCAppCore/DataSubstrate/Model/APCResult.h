// 
//  APCResult.h 
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//
 
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class APCScheduledTask;

@interface APCResult : NSManagedObject

@property (nonatomic, retain) NSString * archiveFilename;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSDate * endDate;
@property (nonatomic, retain) NSString * metaData;
@property (nonatomic, retain) NSString * resultSummary;
@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) NSString * taskID;
@property (nonatomic, retain) NSString * taskRunID;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSNumber * uploaded;
@property (nonatomic, retain) APCScheduledTask *scheduledTask;

@end
