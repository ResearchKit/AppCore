//
//  APCSchedule.h
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 8/28/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface APCSchedule : NSManagedObject

@property (nonatomic, retain) NSString * uid;
@property (nonatomic) NSTimeInterval createdAt;
@property (nonatomic) NSTimeInterval updatedAt;

@end
