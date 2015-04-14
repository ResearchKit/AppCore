// 
//  ORKAnswerFormat+Helper.h 
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
