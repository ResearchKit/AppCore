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

@property (nonatomic, retain) NSNumber * inActive;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSDate * endsOn;
@property (nonatomic, retain) NSString * expires;
@property (nonatomic, retain) NSString * reminderMessage;
@property (nonatomic, retain) NSNumber * shouldRemind;
@property (nonatomic, retain) NSString * scheduleID;
@property (nonatomic, retain) NSString * scheduleString;
@property (nonatomic, retain) NSString * scheduleType;
@property (nonatomic, retain) NSDate * startsOn;
@property (nonatomic, retain) NSString * taskID;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSNumber * remoteUpdatable;
@property (nonatomic, retain) NSNumber * reminderOffset;

@end
