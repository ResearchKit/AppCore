//
//  ORKAnswerFormat+Helper.h
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
//

#import <ResearchKit/ResearchKit.h>

/**
 If you call +[ORKAnswerFormat+Helper stringFromQuestionType],
 and pass an unknown questionType, the returned string will
 be this value.
 */
static NSString * const RKQuestionTypeUnknownAsString = @"UnknownQuestionType";

/**
 Calls +[ORKAnswerFormat+Helper stringFromQuestionType:].
 Please see that method for limitations.
 
 This is named like the Objective-C standard
 "NSStringFrom____()" functions, to make it easier
 to find.  It calls an Objective-C category on
 the class we're actually accessing, to keep all
 our code nice and encapsulated.
 */
extern NSString * NSStringFromRKQuestionType (ORKQuestionType questionType);


/**
 A bucket of utilites for interpreting/parsing/understanding
 ORKAnswerFormat.  Evolving.
 */
@interface ORKAnswerFormat (Helper)

/**
 Converts the specified QuestionType to a string.
 If the specified integer can't be converted to an
 RKQuestionType, returns RKQuestionTypeUnknown.
 
 Used when passing JSON data to Sage.

 Note that this method contains a hard-coded list
 of strings (since we don't have access to the
 ResearchKit source).  If RK adds more question types,
 we'll need to update this method.
 */
+ (NSString *) stringFromQuestionType: (ORKQuestionType) questionType;

@end
