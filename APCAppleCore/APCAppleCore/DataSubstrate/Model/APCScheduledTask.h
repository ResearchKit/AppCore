//
//  APCScheduledTask.h
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 8/29/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class APCResult, APCTask;

@interface APCScheduledTask : NSManagedObject

@property (nonatomic, retain) NSNumber * completed;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSString * notificationUID;
@property (nonatomic, retain) NSDate * dueOn;
@property (nonatomic, retain) APCResult *result;
@property (nonatomic, retain) APCTask *task;

@end
