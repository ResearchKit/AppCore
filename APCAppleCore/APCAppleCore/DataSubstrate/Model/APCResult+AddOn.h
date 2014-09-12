//
//  APCResult+AddOn.h
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 8/29/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCResult.h"
@class RKResult;
@interface APCResult (AddOn)

//Creates it synchronously
+ (APCResult*) storeRKResult:(RKResult*) rkResult inContext: (NSManagedObjectContext*) context;

@end
