//
//  APCResult.h
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 8/29/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class APCScheduledTask;

@interface APCResult : NSManagedObject

@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSNumber * uploaded;
@property (nonatomic, retain) APCScheduledTask *scheduledTask;

@end
