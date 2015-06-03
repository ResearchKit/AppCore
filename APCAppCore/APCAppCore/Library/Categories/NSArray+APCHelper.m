//
//  NSArray+APCHelper.m
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

#import "NSArray+APCHelper.h"
#import "APCUtilities.h"

@implementation NSArray (APCHelper)

+ (instancetype) arrayWithObjectsFromArrays: (NSArray *) firstArray, ...
{
    NSArray *inboundArrays = NSArrayFromVariadicArguments (firstArray);
    NSMutableArray *result = nil;

    /*
     I found a tantalizing suggestion of a built-in Objective-C
     way of doing this:  a call to -valueForKeyPath which runs a
     "collection" operation on the thing you pass it.  There are
     several such operations having to do with the "unions" of
     arrays.  However, they had specific limitations:  "raises
     an exception if such-and-such is nil."  I prefer to write
     stuff so that it never crashes, or appears to crash.
     
     For your information, though, I found it here:
     http://stackoverflow.com/a/17091443
     
     ...which pointed to this official documentation:
     https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/KeyValueCoding/Articles/CollectionOperators.html
     */
    if (inboundArrays.count)
    {
        result = [NSMutableArray new];

        for (id thingy in inboundArrays)
        {
            if ([thingy isKindOfClass: [NSArray class]])
            {
                [result addObjectsFromArray: thingy];
            }
        }
    }

    return result;
}

//    - (NSArray *) arrayBySubtractingObjectsInArray: (NSArray *) otherArray
//    {
//        NSArray *result = nil;
//
//        if (self.count == 0)
//        {
//            result = [NSArray new];
//        }
//        else if (otherArray.count == 0)
//        {
//            result = [NSArray arrayWithArray: self];
//        }
//        else
//        {
//            NSMutableArray *workZone = [NSMutableArray new];
//
//            for (id item in self)
//            {
//                /*
//                 Note that -contains uses -isEqual, which might be expensive,
//                 depending on the objects we're comparing.  This is always
//                 true with doing array operations; it's still worth noting.
//                 */
//                if (! [otherArray containsObject: item])
//                {
//                    [workZone addObject: item];
//                }
//            }
//
//            result = [NSArray arrayWithArray: workZone];
//        }
//
//        return result;
//    }

//    - (NSArray *) arrayBySubtractingObjectsInArrays: (NSArray *) firstArray, ...
//    {
//        NSArray *inboundArrays = NSArrayFromVariadicArguments (firstArray);
//        NSArray *result = nil;
//
//        if (self.count == 0)
//        {
//            result = [NSArray new];
//        }
//
//        else
//        {
//            NSMutableArray *workZone = [NSMutableArray new];
//
//            for (id maybeArray in inboundArrays)
//            {
//                if ([maybeArray isKindOfClass: [NSArray class]])
//                {
//                    [workZone addObjectsFromArray: maybeArray];
//                }
//            }
//
//            result = [NSArray arrayWithArray: workZone];
//        }
//
//        return result;
//    }

//    - (NSArray *) arrayByInsersectingArray: (NSArray *) otherArray
//                   usingComparisonSelector: (SEL) comparisonSelector
//    {
//        NSArray *intersection = nil;
//
//        if (self.count == 0 || otherArray.count == 0)
//        {
//            intersection = [NSArray new];
//        }
//        else
//        {
//            NSMutableArray *temp = [NSMutableArray new];
//
//            for (id item in self)
//            {
//                for (id )
//            }
//
//
//
//
//
//            /*
//             Thanks to http://stackoverflow.com/a/12174070 .
//             */
//            NSMutableSet *mySet = [NSMutableSet setWithArray: self];
//            NSSet *otherSet = [NSSet setWithArray: otherArray];
//            [mySet intersectSet: otherSet];
//            intersection = mySet.allObjects;
//        }
//
//        return intersection;
//    }

- (id) secondObject
{
    id result = nil;

    if (self.count >= 2)
    {
        result = self [1];
    }

    return result;
}

@end










