// 
//  APCDBStatus+AddOn.h 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "APCDBStatus.h"

@interface APCDBStatus (AddOn)

+ (BOOL) isSeedLoadedWithContext: (NSManagedObjectContext*) context;
+ (NSString*) dbStatusVersionwithContext : (NSManagedObjectContext*) context;
+ (void)setSeedLoaded: (NSString*) version WithContext:(NSManagedObjectContext *)context;
+ (void)updateSeedLoaded: (NSString*) version WithContext:(NSManagedObjectContext *)context;

@end
