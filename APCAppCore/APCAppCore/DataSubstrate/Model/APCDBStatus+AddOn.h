// 
//  APCDBStatus+AddOn.h 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "APCDBStatus.h"

@interface APCDBStatus (AddOn)

+ (BOOL) isSeedLoadedWithContext: (NSManagedObjectContext*) context;
+ (void) setSeedLoadedWithContext: (NSManagedObjectContext*) context;

@end
