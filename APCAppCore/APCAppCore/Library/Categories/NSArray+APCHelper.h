//
//  NSArray+APCHelper.h
//  APCAppCore
//
//  Copyright (c) 2015, Apple Inc. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification,
//  are permitted provided that the following conditions are met:
//
//  1.  Redistributions of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer.
//
//  2.  Redistributions in binary form must reproduce the above copyright notice,
//  this list of conditions and the following disclaimer in the documentation and/or
//  other materials provided with the distribution.
//
//  3.  Neither the name of the copyright holder(s) nor the names of any contributors
//  may be used to endorse or promote products derived from this software without
//  specific prior written permission. No license is granted to the trademarks of
//  the copyright holders even if such marks are included in this software.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
//  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
//  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
//  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
//  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
//  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import <Foundation/Foundation.h>

@interface NSArray (APCHelper)

/**
 Because, sometimes, the second object in an array has
 real, meaningful value, such as the 2nd day in a month,
 the 2nd item in a start-and-stop-value array, etc.  In
 those cases, having this -secondObject property avoids
 having "magic numbers" in the code:  hard-coding a "1"
 to access that second array element.
 */
@property (readonly) id secondObject;

/**
 Creates a new array containing the contents of the specified arrays.
 Does not remove duplicates.
 
 Usage:

 @code
 NSArray *myArray = [NSArray arrayWithObjectsFromArrays: someArray, someOtherArray, someThirdArray];
 @endcode
 */
+ (instancetype) arrayWithObjectsFromArrays: (NSArray *) firstArray, ...;

//    /**
//     Creates a new array containing the elements of self which are
//     NOT in otherArray.  Never returns nil (unless self is nil).
//     */
//    - (NSArray *) arrayBySubtractingObjectsInArray: (NSArray *) otherArray;

//    /**
//     Creates a new array containing the elements of self which are
//     also in otherArray.
//     */
//    - (NSArray *) arrayByInsersectingArray: (NSArray *) otherArray
//                   usingComparisonSelector: (SEL) comparisonSelector;

//    /**
//     Creates a new array containing the elements of self which are
//     NOT in any of the specified arrays.  Never returns nil (unless
//     self is nil).
//     
//     Usage:
//
//     @code
//     NSArray *stuffIWantToKeep     = [self getStuffToKeep];
//     NSArray *someStuffIDontWant   = [self getGarbage];
//     NSArray *moreStuffIDontWant   = [self getMoreGarbage];
//     NSArray *lotsOfStuffIDontWant = [self getYetMoreGarbage];
//
//     NSArray *finalList = [stuffIWantToKeep arrayBySubtractingObjectsInArrays: someStuffIDontWant, moreStuffIDontWant, lotsOfStuffIDontWant];
//     @endcode
//     */
//    - (NSArray *) arrayBySubtractingObjectsInArrays: (NSArray *) firstArray, ... ;

@end