//
//  APCResult+AddOn.h
//  APCAppCore
//
//  Created by Dhanush Balachandran on 8/29/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCResult.h"
@class RKSTTaskResult;
@interface APCResult (AddOn)

//Creates it synchronously
+ (NSManagedObjectID*) storeTaskResult:(RKSTTaskResult*) taskResult inContext: (NSManagedObjectContext*) context;

@end
