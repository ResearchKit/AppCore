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

@property (nonatomic, retain) NSData *profileImage;
@property (nonatomic, retain) NSDate * birthDate;
@property (nonatomic, retain) NSNumber * biologicalSex;
@property (nonatomic, retain) NSNumber * bloodType;
@property (nonatomic, retain) NSString * medicalConditions;
@property (nonatomic, retain) NSString * medications;
@property (nonatomic, retain) NSNumber * serverConsented;
@property (nonatomic, retain) NSNumber * userConsented;
@property (nonatomic, retain) NSDate * wakeUpTime;
@property (nonatomic, retain) NSDate * sleepTime;

@end
