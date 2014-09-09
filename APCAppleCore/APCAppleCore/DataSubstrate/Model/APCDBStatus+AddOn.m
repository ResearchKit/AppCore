//
//  APCDBStatus+AddOn.m
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 9/9/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCDBStatus+AddOn.h"
#import "APCAppleCore.h"

@implementation APCDBStatus (AddOn)

+ (BOOL)isSeedLoadedWithContext:(NSManagedObjectContext *)context
{
    NSFetchRequest * request = [APCDBStatus request];
    NSError * error;
    NSArray * array = [context executeFetchRequest:request error:&error];
    [error handle];
    return (array.count > 0);
}

+ (void)setSeedLoadedWithContext:(NSManagedObjectContext *)context
{
    NSAssert(![self isSeedLoadedWithContext:context], @"We should not be loading seed again");
    APCDBStatus * status = [APCDBStatus newObjectForContext:context];
    NSError * error;
    status.status = @"Seed Loaded";
    [status saveToPersistentStore:&error];
    [error handle];
}
@end
