//
//  APCJSONSerializer.m
//  AppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCJSONSerializer.h"
#import "ORKAnswerFormat+Helper.h"
#import "NSDate+Helper.h"
#import <CoreData/CoreData.h>


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
     */
    else if ([sourceObject isKindOfClass: [NSManagedObjectID class]])
    {
        NSManagedObjectID *managedObjectId = (NSManagedObjectID *) sourceObject;
        NSString          *idString        = [NSString stringWithFormat: @"%@", managedObjectId];
        NSRange           uuidRange        = [idString    rangeOfString: kRegularExpressionPatternMatchingUUIDs
                                                                options: NSRegularExpressionSearch];

        if (uuidRange.location == NSNotFound)
        {
            // We can't find a UUID in there.  Just use the whole string.
            // It'll be garbage, but it's at least safely serializable.
            result = idString;
        }
        else
        {
            // Whee!  Found a UUID.  Extract and use that.
            result = [idString substringWithRange: uuidRange];
        }
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
