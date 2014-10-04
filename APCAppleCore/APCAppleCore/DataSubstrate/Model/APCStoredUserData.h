//
//  APCStoredUserData.h
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 9/26/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface APCStoredUserData : NSManagedObject

@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * medicalConditions;
@property (nonatomic, retain) NSString * medications;
@property (nonatomic, retain) NSNumber * consented;
@property (nonatomic, retain) NSDate * wakeUpTime;
@property (nonatomic, retain) NSDate * sleepTime;

@end
