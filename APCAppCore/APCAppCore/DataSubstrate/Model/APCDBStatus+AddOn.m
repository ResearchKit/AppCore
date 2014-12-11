// 
//  APCDBStatus+AddOn.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
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

+ (void)setSeedLoadedWithContext:(NSManagedObjectContext *)context
{
    NSAssert(![self isSeedLoadedWithContext:context], @"We should not be loading seed again");
    [context performBlockAndWait:^{
        APCDBStatus * status = [APCDBStatus newObjectForContext:context];
        NSError * error;
        status.status = @"Seed Loaded";
        [status saveToPersistentStore:&error];
        APCLogError2 (error);
    }];
}
@end
