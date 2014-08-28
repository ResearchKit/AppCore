//
//  APCResult.h
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 8/28/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class APCScheduledTask;

@interface APCResult : NSManagedObject

@property (nonatomic, retain) NSString * uid;
@property (nonatomic) BOOL uploaded;
@property (nonatomic) NSTimeInterval createdAt;
@property (nonatomic) NSTimeInterval updatedAt;
@property (nonatomic, retain) APCScheduledTask *scheduledTask;

@end
