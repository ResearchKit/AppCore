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
 Creates a new array containing the contents of the
 specified arrays.  Does not remove duplicates.

 Usage:

 @code
 NSArray *myArray = [NSArray arrayWithObjectsFromArrays: someArray, someOtherArray, someThirdArray];
 @endcode
 */
+ (instancetype) arrayWithObjectsFromArrays: (NSArray *) firstArray, ...;

/**
 Returns the second object in self, or nil if there is no
 second object.
 
 This method/property is useful because, sometimes,
 the second object in an array has a meaningful purpose:
 the 2nd day in a list of selected days in a month, the
 2nd item in a two-item array of start-and-stop values,
 etc.  In those cases, having this -secondObject property
 avoids having "magic numbers" in the code: hard-coding
 a "1" to access that second array element.
 */
@property (readonly) id secondObject;

/**
 Returns the third object in self, or nil if there is no third object.
 
 This method/property is useful because, sometimes, the third object
 in an array is has a meaningful purpose:  the "end" value in a
 "beginning/middle/end" sequence, for example.  In such cases, having
 this -thirdObject property avoids having "magic numbers" in the code:
 hard-coding a "2" to access that third array element.
 */
@property (readonly) id thirdObject;

/**
 Returns the object at the specified index, or nil if desiredIndex is
 out of bounds for this array.
 */
- (id) safeObjectAtIndex: (NSUInteger) desiredIndex;

@end
