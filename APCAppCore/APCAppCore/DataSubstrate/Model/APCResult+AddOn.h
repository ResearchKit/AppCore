// 
//  APCResult+AddOn.h 
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//
 
#import "APCResult.h"
@class ORKTaskResult;
@interface APCResult (AddOn)

//Creates it synchronously
+ (NSManagedObjectID*) storeTaskResult:(ORKTaskResult*) taskResult inContext: (NSManagedObjectContext*) context;

+ (APCResult*) findAPCResultFromTaskResult: (ORKTaskResult*) taskResult inContext: (NSManagedObjectContext*) context;
+ (BOOL) updateResultSummary: (NSString*) summary forTaskResult:(ORKTaskResult *)taskResult inContext:(NSManagedObjectContext *)context;
@end
