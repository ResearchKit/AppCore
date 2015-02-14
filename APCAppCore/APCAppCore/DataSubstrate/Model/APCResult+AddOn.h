// 
//  APCResult+AddOn.h 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "APCResult.h"
@class RKSTTaskResult;
@interface APCResult (AddOn)

//Creates it synchronously
+ (NSManagedObjectID*) storeTaskResult:(RKSTTaskResult*) taskResult inContext: (NSManagedObjectContext*) context;

@end
