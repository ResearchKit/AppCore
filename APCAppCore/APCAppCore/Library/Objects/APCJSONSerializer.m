// 
//  APCJSONSerializer.m 
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
 
#import "APCJSONSerializer.h"
#import "ORKAnswerFormat+Helper.h"
#import "NSDate+Helper.h"
#import <CoreData/CoreData.h>



/**
 Publicly-declared constants (in my header file).

 These constants are used by a couple of different classes
 which prepare stuff for me to serialize.

 Imported (stolen, duplicated) from APCDataArchiver.
 Working on normalizing that.
 */
NSString * const kAPCSerializedDataKey_QuestionType            = @"questionType";
NSString * const kAPCSerializedDataKey_QuestionTypeName        = @"questionTypeName";
NSString * const kAPCSerializedDataKey_UserInfo                = @"userInfo";
NSString * const kAPCSerializedDataKey_Identifier              = @"identifier";
NSString * const kAPCSerializedDataKey_Item                    = @"item";
NSString * const kAPCSerializedDataKey_TaskRun                 = @"taskRun";
NSString * const kAPCSerializedDataKey_Files                   = @"files";
NSString * const kAPCSerializedDataKey_AppName                 = @"appName";
NSString * const kAPCSerializedDataKey_AppVersion              = @"appVersion";
NSString * const kAPCSerializedDataKey_FileInfoName            = @"filename";
NSString * const kAPCSerializedDataKey_FileInfoTimeStamp       = @"timestamp";
NSString * const kAPCSerializedDataKey_FileInfoContentType     = @"contentType";



/**
 We use this regular-expression pattern to extract UUIDs
 from CoreData object IDs.
 */
static NSString * const kRegularExpressionPatternMatchingUUIDs = (@"[a-fA-F0-9]{8}\\-"
                                                                  "[a-fA-F0-9]{4}\\-"
                                                                  "[a-fA-F0-9]{4}\\-"
                                                                  "[a-fA-F0-9]{4}\\-"
                                                                  "[a-fA-F0-9]{12}");


@implementation APCJSONSerializer

/**
 The public API.  See comments in the header file.
 */
+ (NSDictionary *) serializableDictionaryFromSourceDictionary: (NSDictionary *) sourceDictionary
{
    NSDictionary *result = [self serializableDictionaryFromSourceDictionary: sourceDictionary
                                                           atRecursionDepth: 0];

    return result;
}

/**
 This method is just a switch.  It calls separate conversion
 methods depending on whether sourceObject is a dictionary,
 an array, or a "simple" object (anything other than a 
 dictionary or an array).

 @param recursionDepth:  How far down this recursive conversion stack
 we are.  This matters because one of our conversions only happens at
 the top level of an incoming dictionary.  Only -serializableArray...:
 and -serializableDictionary...: should modify recursionDepth; all
 other methods should pass it through as-is.
 
 @return If you pass a dictionary, you'll receive a dictionary;
 if you pass an array, you'll get an array.  Every other object
 may be converted to something vastly different from what you 
 pass in -- e.g., NSDates get converted to a precisely-formatted
 NSString.
 */
+ (id) serializableObjectFromSourceObject: (id) sourceObject
                         atRecursionDepth: (NSUInteger) recursionDepth
{
    id result = nil;

    if ([sourceObject isKindOfClass: [NSArray class]])
    {
        result = [self serializableArrayFromSourceArray: sourceObject
                                       atRecursionDepth: recursionDepth];
    }

    else if ([sourceObject isKindOfClass: [NSDictionary class]])
    {
        result = [self serializableDictionaryFromSourceDictionary: sourceObject
                                                 atRecursionDepth: recursionDepth];
    }

    else
    {
        result = [self serializableSimpleObjectFromSourceSimpleObject: sourceObject];
    }

    return result;
}

+ (NSArray *) serializableArrayFromSourceArray: (NSArray *) sourceArray
                              atRecursionDepth: (NSUInteger) recursionDepth
{
    NSMutableArray *resultArray = [NSMutableArray new];

    for (id value in sourceArray)
    {
        id convertedValue = [self serializableObjectFromSourceObject: value
                                                    atRecursionDepth: recursionDepth + 1];

        if (convertedValue != nil)
        {
            [resultArray addObject: convertedValue];
        }
    }

    return resultArray;
}

+ (NSDictionary *) serializableDictionaryFromSourceDictionary: (NSDictionary *) sourceDictionary
                                             atRecursionDepth: (NSUInteger) recursionDepth
{
    NSMutableDictionary *resultDictionary = [NSMutableDictionary new];

    for (NSString *key in sourceDictionary)
    {
        id value = sourceDictionary [key];

        //
        // Find and include the names for RKQuestionTypes.
        //
        if ([key isEqualToString: kAPCSerializedDataKey_QuestionType])
        {
            id valueToSerialize = nil;
            NSString* nameToSerialize = nil;

            NSNumber *questionType = [self extractRKQuestionTypeFromNSNumber: value];

            if (questionType != nil)
            {
                valueToSerialize = questionType;
                nameToSerialize = NSStringFromRKQuestionType (questionType.integerValue);
            }
            else
            {
                valueToSerialize = [self safeSerializableItemFromItem: value];
                nameToSerialize = RKQuestionTypeUnknownAsString;
            }

            resultDictionary [kAPCSerializedDataKey_QuestionType] = valueToSerialize;
            resultDictionary [kAPCSerializedDataKey_QuestionTypeName] = nameToSerialize;
        }

        //
        // Treat other keys and values normally...
        //
        else
        {
            id convertedKey = key;
            id convertedValue = nil;


            //
            // ...with one exception:  at the top level only, convert
            // the key "identifier" to the key "item".
            //
            // Not sure why.  (It's historical.)  Still investigating.
            // Discovered so far:
            // -  this is used for the outbound filename
            // -  ?
            // -  ?
            //
            if (recursionDepth == 0 && [key isEqualToString: kAPCSerializedDataKey_Identifier])
            {
                convertedKey = kAPCSerializedDataKey_Item;
            }
            else
            {
                // "else" nothing.  This applies to every other decision.
            }


            convertedValue = [self serializableObjectFromSourceObject: value
                                                     atRecursionDepth: recursionDepth + 1];

            if (convertedValue != nil)
            {
                resultDictionary [convertedKey] = convertedValue;
            }
        }
    }

    return resultDictionary;
}

/**
 A "simple object" is anything that's not an NSDictionary or an
 NSArray.
 */
+ (id) serializableSimpleObjectFromSourceSimpleObject: (id) sourceObject
{
    id result = nil;

    /*
     Delete calendars.
     */
    if ([sourceObject isKindOfClass: [NSCalendar class]])
    {
        // Return nil.  This tells the calling method to omit this item.
    }

    /*
     Make dates "ISO-8601 compliant."  Meaning, format
     them like this:

     2015-02-25T16:42:11+00:00

     Per Sage.  I got the rules from:  http://en.wikipedia.org/wiki/ISO_8601
     */
    else if ([sourceObject isKindOfClass: [NSDate class]])
    {
        NSDate *theDate = (NSDate *) sourceObject;
        NSString *sageFriendlyDate = theDate.toStringInISO8601Format;
        result = sageFriendlyDate;
    }

    /*
     Extract strings from UUIDs.
     */
    else if ([sourceObject isKindOfClass: [NSUUID class]])
    {
        NSUUID *uuid = (NSUUID *) sourceObject;
        NSString *uuidString = uuid.UUIDString;
        result = uuidString;
    }

    /*
     Convert stringified ints and bools to their real values.

     Very commonly, we have strings that actually contains integers or
     Booleans -- as answers to multiple-choice questions, say. However,
     much earlier in this process, they got converted to strings. This
     seems to be a core feature of ResearchKit. But there's still value
     in them being numeric or Boolean answers. So try to convert each
     item to an integer or Boolean. If we can't, just call our master
     -safe: method to make sure we can serialize it.
     */
    else if ([sourceObject isKindOfClass: [NSString class]])
    {
        result = [self extractIntOrBoolFromString: sourceObject];

        if (result == nil)
        {
            // If we couldn't numeric-ify it, use the original string.
            result = sourceObject;
        }
        else
        {
            // Numericification worked.
            // Accept the object we got from -extractIntOrBoolFromString.
        }
    }


    /*
     Extract the UUID part of a CoreData ID, if we can.
     
     Note that this will work "just fine" if it's a CoreData
     temporary ID.  But if that happens, you're probably
     sending a temporary ID to a server, which may not be
     what you want.
     */
    else if ([sourceObject isKindOfClass: [NSManagedObjectID class]])
    {
        NSManagedObjectID *managedObjectId = (NSManagedObjectID *) sourceObject;
        NSString *idString = managedObjectId.URIRepresentation.absoluteString;              // --> "x-coredata://73F057D0-BE34-4D67-8AF1-A25DB2D70774/APCMedTrackerPrescription/p1"
        idString = [idString substringFromIndex: @"x-coreData://".length];                  // -->              "73F057D0-BE34-4D67-8AF1-A25DB2D70774/APCMedTrackerPrescription/p1"
        idString = [idString stringByReplacingOccurrencesOfString: @"/" withString: @"-"];  // -->              "73F057D0-BE34-4D67-8AF1-A25DB2D70774-APCMedTrackerPrescription-p1"
        result = idString;
    }


    /*
     Everything Else

     If we get here:  we want to keep it, but don't have specific
     rules for converting it.  Use our default serialization process:
     include it as-is if the serializer recognizes it, or convert it
     to a string if not.
     */
    else
    {
        result = [self safeSerializableItemFromItem: sourceObject];
    }


    /*
     Whew.
     */
    return result;
}

/**
 Try to convert the specified item to an NSNumber, specifically
 if it's a String that looks like a Boolean or an intenger.
 */
+ (NSNumber *) extractIntOrBoolFromString: (NSString *) itemAsString
{
    NSNumber *result = nil;

    if (itemAsString.length > 0)
    {
        if ([itemAsString compare: @"no" options: NSCaseInsensitiveSearch] == NSOrderedSame ||
            [itemAsString compare: @"false" options: NSCaseInsensitiveSearch] == NSOrderedSame)
        {
            result = @(NO);
        }

        else if ([itemAsString compare: @"yes" options: NSCaseInsensitiveSearch] == NSOrderedSame ||
                 [itemAsString compare: @"true" options: NSCaseInsensitiveSearch] == NSOrderedSame)
        {
            result = @(YES);
        }

        else
        {
            NSInteger itemAsInt = itemAsString.integerValue;
            NSString *verificationString = [NSString stringWithFormat: @"%d", (int) itemAsInt];

            // Here, we use -isValidJSONObject: to make sure the int isn't
            // NaN or infinity.  According to the JSON rules, those will
            // break the serializer.
            if ([verificationString isEqualToString: itemAsString] && [NSJSONSerialization isValidJSONObject: @[verificationString]])
            {
                result = @(itemAsInt);
            }

            else
            {
                // It was NaN or infinity.  Therefore, we can't convert it
                // to a safe or serializable value.  Ignore it.
            }
        }
    }

    return result;
}

/**
 Try to convert the specified Number to an RKQuestionType.
 */
+ (NSNumber *) extractRKQuestionTypeFromNSNumber: (NSNumber *) item
{
    NSNumber* result = nil;

    if ([NSJSONSerialization isValidJSONObject: @[item]])
    {
        ORKQuestionType questionType = item.integerValue;
        result = @(questionType);
    }

    return result;
}

/**
 If we can serialize the specified item, return it.
 Otherwise, converts it to a string and returns the
 string.

 Things we can serialize are strings, numbers, NSNulls,
 and arrays or dictionaries of those things (potentially
 infinitely deep).  Numbers are OK as long as they're not
 NaN or infinity.

 Note that the REAL rules say we should call this method:

        [NSJSONSerialization isValidJSONObject:]

 instead of using, like, our brains, or other logic.
 Which means (I guess) that Apple reserves the right to
 decide what can and cannot be serialized, as they
 upgrade NSJSONSerializer.

 Details:
 https://developer.apple.com/library/ios/documentation/Foundation/Reference/NSJSONSerialization_Class/
 */
+ (id) safeSerializableItemFromItem: (id) item
{
    id result = nil;

    /*
     -isValidJSONObject: can only take an array or
     dictionary at its top level.  So wrap this item
     in an array.
     */
    NSArray *itemToEvaluate = @[item];
    
    if ([NSJSONSerialization isValidJSONObject: itemToEvaluate])
    {
        result = item;
    }
    else
    {
        result = [NSString stringWithFormat: @"%@", item];
    }
    
    return result;
}

@end
