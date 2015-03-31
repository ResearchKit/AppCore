// 
//  APCDBStatus+AddOn.m 
//  APCAppCore 
// 
// Copyright (c) 2015, Apple Inc. All rights reserved. 
// 
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
// 
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
// 
// 2.  Redistributions in binary form must reproduce the above copyright notice, 
// this list of conditions and the following disclaimer in the documentation and/or 
// other materials provided with the distribution. 
// 
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors 
// may be used to endorse or promote products derived from this software without 
// specific prior written permission. No license is granted to the trademarks of 
// the copyright holders even if such marks are included in this software. 
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE 
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
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
