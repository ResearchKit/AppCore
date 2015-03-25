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

    /*
     TESTING

     Please leave this commented-out line of code in here.
     It helps us test complex errors that might be returned.
     It calls the matching method at the bottom of this file.

        folderCreated = [self generateGenericComplexErrorObject:  & folderCreationError];
     */


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


//    /**
//     TESTING
//
//     Please leave this method in this file.
//     It helps us test complex errors that might be returned.
//     */
//    - (BOOL) generateGenericComplexErrorObject: (NSError **) errorToReturn
//    {
//        NSDictionary *randomNestedDictionary2 = @{@"one": @(1),
//                                                  @"two": @(2),
//                                                  @"three": @"some string with\nnewlines\nin it"
//                                                  };
//
//        NSDictionary *randomNestedDictionary1 = @{@"fred": @"dude!",
//                                                  @"fredsAge": @(45),
//                                                  @"yet another random dictionary": randomNestedDictionary2
//                                                  };
//
//        NSError *randomNestedError = [NSError errorWithDomain: @"random nested error"
//                                                         code: 15
//                                                     userInfo: nil
//                                      ];
//
//        NSDictionary *topLevelUserInfo = @{ NSUnderlyingErrorKey   : randomNestedError,
//                                            @"randomSubDictionary" : randomNestedDictionary1
//                                            };
//
//        if (errorToReturn != nil)
//        {
//            *errorToReturn = [NSError errorWithDomain: @"hooray! we're testing."
//                                                 code: 0
//                                             userInfo: topLevelUserInfo
//                              ];
//        }
//
//        return NO;
//    }

@end

















