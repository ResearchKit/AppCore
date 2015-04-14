// 
//  APCScheduleExpressionParser.h 
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
#import "APCListSelector.h"
#import "APCPointSelector.h"

/**
 Interprets a cron-style schedule-expression string
 as a set of useful fields:  hours, minutes, days,
 months, years, etc.  For example, "* 12 * * *" means
 "every day at noon."
 
 Conceptually, a parser verifies whether a string conforms
 to a set of rules, called a "grammar."  The parser can
 also return items in groups, or in a tree, representing
 the stuff that was successfully identified as matching
 that grammar.  The parser does not, and should not, know
 anything (or much) about how that stuff will be used,
 though.
 
 The grammar is below.

 There's nothing automatic about this.  The class
 manually calls methods to perform each of these rules
 in the appropriate places.  I.e., we've hand-written
 a parser that implements these rules.
 
 Read the rules from bottom to top.  Lower items in the
 list of rules are lower in precedence; higher items are
 higher in precedence.  For example, reading from bottom
 to top:
 - LISTs...
 - can contain RANGEs...
 - which might contain STEPs...
 - which must contain DIGITs.

 Special characters roughly follow the conventions for "regular expressions":
	?		 means  "0 or 1 of the preceding item"
	+		 means  "1 or more of the preceding item"
	*		 means  "0 or more of the preceding item"
	|		 means  "either the stuff on the left or the right, but not both"
	( ... )  means  "consider all this stuff as a group"
 
 Enough hemming and hawing.  Here's the grammar:

	digit				:: '0'..'9'
	wildcard			:: '*' | '?'
	whitespace			:: ' ' | '\t' | '\n' | '\r' | (other non-printing chars)

	rangeSeparator		:: '-'
	positionSeparator	:: '#'
	stepSeparator		:: '/'
	listSeparator		:: ','
	fieldSeparator		:: whitespace

	monthName			:: "jan" through "dec", case-insensitive
	weekdayName			:: "sun" through "sat", case-insensitive
	number				:: digit +

	positionIdentifier	:: number
	stepCount			:: number

	secondsNumber		:: number, 0-59
	minuteNumber		:: number, 0-59
	hourNumber			:: number, 0-59
	dayNumber			:: number, 1-31
	monthNumber			:: number, 1-12
	weekdayNumber		:: number, 0-7    (because both 0 and 7 are legal cron-speak for "Sunday")
	yearNumber			:: number

	itemName			:: monthName     | weekdayName
	itemNumber			:: secondsNumber | minuteNumber | hourHumber | dayNumber | monthNumber | weekdayNumber | yearNumber
	item				:: itemNumber    | itemName
	range				:: item ( rangeSeparator item ) ?
	rangeSpec			:: wildcard | range
	expression			:: rangeSpec ( stepSeparator stepCount | positionSeparator positionIdentifier ) ?
	list				:: expression ( listSeparator expression ) *

	yearList			:: list		\
	weekdayList			:: list		|	We'll gather as many lists as we have.
	monthList			:: list		|	Then we'll do some careful analysis to
	dayOfMonthList		:: list		|	figure out which lists are the monthList
	hoursList			:: list		|	and weekdayList, delete the secondList and
	minutesList			:: list		|	yearList, and assign the rest accordingly.
	secondsList			:: list		/
 
	fields				:: ( whitespace ? ) ( secondsList fieldSeparator ) ? minutesList fieldSeparator hoursList fieldSeparator dayOfMonthList fieldSeparator monthList dayOfWeekList fieldSeparator yearList ( whitespace ? )
 */
@interface APCScheduleExpressionParser : NSObject

@property (nonatomic, strong) APCTimeSelector*    minuteSelector;
@property (nonatomic, strong) APCTimeSelector*    hourSelector;
@property (nonatomic, strong) APCTimeSelector*    dayOfMonthSelector;
@property (nonatomic, strong) APCTimeSelector*    monthSelector;
@property (nonatomic, strong) APCTimeSelector*    yearSelector;

- (instancetype)initWithExpression:(NSString*)expression;

/**
 *  The validity of the parsed expression.
 *
 *  @return Returns a _YES_ value if the parse is at the _end_ and no errors have been encountered.
 */
- (BOOL)isValidParse;

- (BOOL)parse;


/*
 Private, but we sometimes call these from the test harness.
 So, um, please don't use these.
 */
- (NSArray*)rangeProduction;
- (NSNumber*)stepsProduction;
- (APCListSelector*)listProduction;
- (void)coerceSelector:(APCListSelector *)list intoType:(UnitType)type;

@end






