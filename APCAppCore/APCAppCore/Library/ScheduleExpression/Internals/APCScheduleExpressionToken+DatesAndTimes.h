//
//  APCScheduleExpressionToken+DatesAndTimes.h
//  APCAppCore
//
//  Created by Ron Conescu on 1/9/15.
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCScheduleExpressionToken.h"


/**
 This category lets us interpret the Token as a useful
 calendar item:  a month, weekday, etc.
 
 Putting these features into a category is a semantic
 design decision.  Here's the idea:
 
 This is a bunch of functions for interpreting tokens.
 Tokens, by design, do not and should not understand
 their own MEANING; that's the job of the parser, or
 something farther downstream than that.  But when I
 put these in the parser, they look messy:  they're
 a bunch of topically related methods which aren't
 specific to the CONCEPT of a parser, just this specific
 use of one. 
 
 Objective-C categories work well for solving this sort
 of problem:  a bunch of methods specific to topic A,
 but which are only needed by stuff outside of A.
 Hence this file.

 Again:  this is NOT part of the concept of a "token."
 This is a set of tools for USING tokens.
 
 To make sure we remember that, all these method names
 are called "blah-blah-blah-INTERPRET-blah-blah-blah".
 */
@interface APCScheduleExpressionToken (DatesAndTimes)

@property (readonly) BOOL canInterpretAsSeconds;
@property (readonly) BOOL canInterpretAsMinutes;
@property (readonly) BOOL canInterpretAsHours;
@property (readonly) BOOL canInterpretAsDay;
@property (readonly) BOOL canInterpretAsMonth;
@property (readonly) BOOL canInterpretAsWeekday;

@property (readonly) NSInteger interpretAsSeconds;
@property (readonly) NSInteger interpretAsMinutes;
@property (readonly) NSInteger interpretAsHours;
@property (readonly) NSInteger interpretAsDay;
@property (readonly) NSInteger interpretAsMonth;
@property (readonly) NSInteger interpretAsWeekday;

@end
