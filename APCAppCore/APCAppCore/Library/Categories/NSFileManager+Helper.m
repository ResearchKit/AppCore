//
// NSFileManager+Helper.m
// AppCore
//
// Copyright (c) 2015 Apple, Inc. All rights reserved.
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

#import "NSFileManager+Helper.h"

@implementation NSFileManager (Helper)

- (BOOL) createAPCFolderAtPath: (NSString *) path
                returningError: (NSError * __autoreleasing *) errorToReturn
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
//    - (BOOL) generateGenericComplexErrorObject: (NSError * __autoreleasing *) errorToReturn
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

















