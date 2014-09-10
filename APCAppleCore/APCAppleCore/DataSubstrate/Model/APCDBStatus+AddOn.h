//
//  APCDBStatus+AddOn.h
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 9/9/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCDBStatus.h"

@interface APCDBStatus (AddOn)

+ (BOOL) isSeedLoadedWithContext: (NSManagedObjectContext*) context;
+ (void) setSeedLoadedWithContext: (NSManagedObjectContext*) context;

@end
