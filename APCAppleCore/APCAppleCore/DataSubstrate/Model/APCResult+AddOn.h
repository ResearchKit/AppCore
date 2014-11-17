//
//  APCResult+AddOn.h
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 8/29/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCResult.h"
@class RKSTResult;
@interface APCResult (AddOn)

//Creates it synchronously
+ (instancetype) storeRKSTResult:(RKSTResult*) rkResult inContext: (NSManagedObjectContext*) context;
+ (void) mapRKSTResult:(RKSTResult*) rkResult toAPCResult: (APCResult*) apcResult;

@end
