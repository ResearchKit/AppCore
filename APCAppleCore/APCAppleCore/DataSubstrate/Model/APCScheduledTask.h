//
//  APCScheduledTask.h
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 8/28/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class APCTask;

@interface APCScheduledTask : NSManagedObject

@property (nonatomic) NSTimeInterval createdAt;
@property (nonatomic) NSTimeInterval updatedAt;
@property (nonatomic) BOOL completed;
@property (nonatomic, retain) APCTask *task;
@property (nonatomic, retain) NSManagedObject *result;

@end
