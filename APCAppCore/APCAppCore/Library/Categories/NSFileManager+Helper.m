//
//  NSFileManager+Helper.m
//  APCAppCore
//
//  Created by Ron Conescu on 3/19/15.
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "NSFileManager+Helper.h"

@implementation NSFileManager (Helper)

- (BOOL) createAPCFolderAtPath: (NSString *) path
                returningError: (NSError **) errorToReturn
{
    NSError *folderCreationError = nil;

    BOOL folderCreated = [self createDirectoryAtPath: path
                                withIntermediateDirectories: YES
                                                 attributes: @{ NSFileProtectionKey : NSFileProtectionCompleteUntilFirstUserAuthentication }
                                                      error: & folderCreationError];


    if (folderCreated)
    {
        // Hooray!
    }

    else
    {
        // Something broke.  Return the provided error, if requested.
        if (errorToReturn != nil)
        {
            *errorToReturn = folderCreationError;
        }
    }

    return folderCreated;
}

@end
