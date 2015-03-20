//
//  NSFileManager+Helper.m
//  AppCore
//
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

//    // TESTING
//    folderCreated = NO;
//    folderCreationError = [NSError errorWithDomain: @"Ron is testing"
//                                              code: 0
//                                          userInfo: @{ @"randomSubDictionary": @{
//                                                               @"fred": @"dude!",
//                                                               @"fredsAge": @(45),
//                                                               @"yet another random dictionary": @{ @"one": @(1),
//                                                                                                    @"two": @(2),
//                                                                                                    @"three": @"some string with\nnewlines\nin it"
//                                                                                                    }
//                                                               },
//                                                       NSUnderlyingErrorKey: [NSError errorWithDomain: @"random nested error"
//                                                                                                 code: 15
//                                                                                             userInfo: nil
//                                                                              ]
//                                                       }];

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
