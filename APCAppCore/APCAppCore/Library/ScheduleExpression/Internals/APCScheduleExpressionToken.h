// 
//  APCScheduleExpressionToken.h 
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
 
#import <Foundation/Foundation.h>


static NSInteger const kAPCScheduleExpressionTokenIntegerValueNotSet = -1;


/**
 This enum is the list of possible types of tokens in our
 cron-expression parser.
 
 For each token, we give examples of how that token will be
 used by the parser.  Note that the tokens don't know what
 they themselves MEAN; they're just strings of characters
 and/or (if possible) integers.  We give these examples
 just to help the tokens types make sense in context:  we're
 writing a parser with a specific purpose, and that purpose
 gave us the list of stuff that's legal for a "token."
 */
typedef enum : NSUInteger {

	/**
	 Internal state to track the fact that the token
	 has been initialized, but nothing has been
	 scanned, yet.  You should never see this.
	 If you get this, the -didEncounterError field
	 will also be set, and the -errorMessage will be
	 yelping about how unlikely this is.
	 */
	APCScheduleExpressionTokenTypeNotYetParsed,

	/**
	 A string of plain-text characters, case-insensitive:
	 A..Z and a..z.
	 
	 Example:  * * * MAR,apr,May THU,frI,mOn
	
	 Meaning:  This example means "every March, April,
	 and May, on Monday, Thursday, and Friday."  Note that
	 this token merely recognizes strings of characters; it
	 doesn't know what the characters MEAN.  The following
	 example would also be accepted by the tokenizer:
	 
	 Example:  * * * dude likeTotally
	 
	 ...although the parser, when it received this token,
	 would reject those values as invalid month and weekday
	 names.
	 */
	APCScheduleExpressionTokenTypeWord,

	/**
	 A string of digits.
	 
	 Example:  17
	 
	 Meaning:  depends on where it occurs.  In the "minutes"
	 field, means "17 minutes after the hour."  In the "hours"
	 field, means "5 pm."  In the "month" field, the parser will
	 reject this as illegal (we only have 12 months in the
	 Gregorian calendar).  Etc.

	 Note:  Despite the name of this enum value, this is not a
	 full-fledged C-style numeric value (which also allows "+",
	 "-", ".", and "e").  This is just the digits 0 through 9.
	 */
	APCScheduleExpressionTokenTypeNumber,
	
	/*
	 "?" or "*".
	 
	 Example:  0 12 * ? *
	 
	 Meaning:  Noon of every day, in every month, in every year.
	 In our parser (and in every example we've seen in real life),
	 the "*" and "?" wildcards are equivalent.
	 */
	APCScheduleExpressionTokenTypeWildcard,

	/**
	 A comma:  ","
	 
	 Example:  MON,THU,FRI
	 
	 Meaning:  Just what it looks like:
	 a list of days of the week.  Note that
	 spaces are not legal around the ",".  See
	 APCScheduleExpressionTokenTypeFieldSeparator
	 for more information about that.
	 */
	APCScheduleExpressionTokenTypeListSeparator,

	/**
	 A forward-slash:  "/"
	 
	 Example:  JUN-DEC/3  

	 Meaning:  Every third month from June through
	 December, starting in June.
	 */
	APCScheduleExpressionTokenTypeStepSeparator,
	
	/**
	 Whitespace.
	 
	 Example:  * 12 * jan,feb *
	 
	 Meaning:  Noon on every day of January and February.
	 The spaces separate the minute, hour, day, month,
	 and day-of-week fields.  A space within the "jan,feb"
	 string, like "jan, feb", would be interpreted as
	 illegal:  it would make the parser interpret "feb"
	 as the 5th field, i.e., a day of the week.
	 
	 In other words : in this "cron" language, whitespace
	 is significant:  it's a character class that separates
	 minutes from hours from days from months from days-of-week.
	 It's a real, meaningful token, not "stuff we can just ignore."
	 */
	APCScheduleExpressionTokenTypeFieldSeparator,

	/**
	 A hyphen:  "-"
	 
	 Example:  5-10
	 
	 Meaning:  Depends on where it occurs.  In the
	 "hour" field, means "every hour from 5am to 10am."
	 In the "month" field, it means "every month from
	 May through October."  Etc.
	 */
	APCScheduleExpressionTokenTypeRangeSeparator,

	/**
	 A hash sign:  "#"
	 
	 Example:  thu#3
	 
	 Meaning:  The third Thursday of the month.
	 Only legal in the "day of week" field.
	 */
	APCScheduleExpressionTokenTypePositionSeparator,

	/**
	 We got a string of characters that don't
	 fall into any of the character classes we know
	 about.  If you get this, the -didEncounterError
	 property will be set, and the unrecognized text
	 will be in the -stringValue property, so you can
	 print it.
	 
	 Example:  * * * &%$$@! *
	 
	 Meaning:  This expression requests a month named
	 "&%$$@!"  We don't have one in the Gregorian
	 calendar.  :-)
	 */
	APCScheduleExpressionTokenTypeUnrecognized,

	/*
	 We couldn't scan at all.  If you get this,
	 -didEncounterError will be YES, -errorMessage
	 will describe the problem, and -stringValue will be nil.
	 */
	APCScheduleExpressionTokenTypeScanningError,

} APCScheduleExpressionTokenType;


/**
 Represents the contents found in a cron-style 
 schedule-expression string.
 
 Conceptually, this class is a struct -- a simple
 piece of data -- not a class.  It knows how to break
 the input string into words, numbers, or specific
 pieces of punctuation.  It does not, and should not,
 know how that stuff is going to be USED; that's the
 parser's job.
 
 Objects of this class are generated by
 APCScheduleExpressionParser, and used by
 APCScheduleExpressionTokenizer.  See
 APCScheduleExpressionTokenType, and
 APCScheduleExpressionParser.h for the possible types
 of tokens and how they're used.

 Note that we also have a category on this class:
 APCScheduleExpressionToken(DatesAndTimes).
 The reason:  this class, by itself, represents tokens
 without any sense of meaning.  The category is used much
 later in the interpretation process, and helps us
 understand and extract the meaning of the token in a
 given context.
 */
@interface APCScheduleExpressionToken : NSObject

// Stuff we might scan
@property (nonatomic, assign) NSInteger  integerValue;
@property (nonatomic, strong) NSString*  stringValue;
@property (nonatomic, assign) NSUInteger countOfScannedCharacters;

// Recording what happened when scanning the above
@property (nonatomic, assign) APCScheduleExpressionTokenType type;
@property (nonatomic, assign) BOOL didEncounterError;
@property (nonatomic, strong) NSString* errorMessage;

// Easy accessor methods for every type of token we recognize.
// You can also check the -type property directly.
@property (readonly) BOOL isWord;
@property (readonly) BOOL isNumber;
@property (readonly) BOOL isWildcard;
@property (readonly) BOOL isListSeparator;
@property (readonly) BOOL isStepSeparator;
@property (readonly) BOOL isFieldSeparator;
@property (readonly) BOOL isRangeSeparator;
@property (readonly) BOOL isPositionSeparator;

/// If this value is ever YES, something went wrong.
@property (readonly) BOOL isNotYetParsed;

/// Can also check -didEncounterError.
@property (readonly) BOOL isUnrecognized;

/// Can also check -didEncounterError.
@property (readonly) BOOL isScanningError;

@end







