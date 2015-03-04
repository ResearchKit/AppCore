// 
//  APCDBStatus+AddOn.m 
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
//
 
#import "APCDBStatus+AddOn.h"
#import "APCAppCore.h"


@implementation APCDBStatus (AddOn)

+ (BOOL)isSeedLoadedWithContext:(NSManagedObjectContext *)context
{
    __block NSArray * array;
    [context performBlockAndWait:^{
        NSFetchRequest * request = [APCDBStatus request];
        NSError * error;
        array = [context executeFetchRequest:request error:&error];
        APCLogError2 (error);
    }];
    return (array.count > 0);
}

+ (NSString*) dbStatusVersionwithContext : (NSManagedObjectContext*) context
{
    __block NSArray * array;
    [context performBlockAndWait:^{
        NSFetchRequest * request = [APCDBStatus request];
        NSError * error;
        array = [context executeFetchRequest:request error:&error];
        APCLogError2 (error);
    }];
    return array.count > 0 ? [(APCDBStatus*) array.firstObject status] : nil;
}

+ (void)setSeedLoaded: (NSString*) version WithContext:(NSManagedObjectContext *)context
{
    NSAssert(![self isSeedLoadedWithContext:context], @"We should not be loading seed again");
    [context performBlockAndWait:^{
        APCDBStatus * status = [APCDBStatus newObjectForContext:context];
        NSError * error;
        status.status = version;
        [status saveToPersistentStore:&error];
        APCLogError2 (error);
    }];
}

+ (void)updateSeedLoaded: (NSString*) version WithContext:(NSManagedObjectContext *)context
{
    [context performBlockAndWait:^{
        NSArray * array;
        NSFetchRequest * request = [APCDBStatus request];
        NSError * error;
        array = [context executeFetchRequest:request error:&error];
        APCDBStatus * status = array.firstObject;
        APCLogError2 (error);
        status.status = version;
        [status saveToPersistentStore:&error];
        APCLogError2 (error);
    }];
}
@end
