//
//  APCSchedule.h
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 11/24/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface APCSchedule : NSManagedObject

@property (nonatomic, retain) NSNumber * active;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSDate * endsOn;
@property (nonatomic, retain) NSString * expires;
@property (nonatomic, retain) NSString * notificationMessage;
@property (nonatomic, retain) NSString * reminder;
@property (nonatomic, retain) NSString * scheduleString;
@property (nonatomic, retain) NSString * scheduleType;
@property (nonatomic, retain) NSString * source;
@property (nonatomic, retain) NSDate * startsOn;
@property (nonatomic, retain) NSString * taskID;
@property (nonatomic, retain) NSString * scheduleID;
@property (nonatomic, retain) NSDate * updatedAt;

@end
