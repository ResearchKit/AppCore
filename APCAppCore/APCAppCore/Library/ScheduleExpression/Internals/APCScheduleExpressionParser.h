// 
//  APCScheduleExpressionParser.h 
//  AppCore 
// 
//  Copyright (c) 2015 Apple Inc. All rights reserved. 
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
	monthName			:: "jan" through "dec", case-insensitive
	weekdayName			:: "sun" through "sat", case-insensitive

	rangeSeparator		:: '-'
	positionSeparator	:: '#'
	stepSeparator		:: '/'
	listSeparator		:: ','
	fieldSeparator		:: whitespace

	number				:: digit +
	position			:: number
	steps				:: number
	month				:: number | monthName
	weekday				:: number | weekdayName
                    	
	range				:: number  ( rangeSeparator number ) ?
	monthRange			:: month   ( rangeSeparator month  ) ?
	weekdayRange		:: weekday ( rangeSeparator weekday ) ?
                    	
	numspec				:: wildcard | range
	monthSpec			:: wildcard | monthRange
	weekdaySpec			:: wildcard | weekdayRange
                    	
	expr				:: numspec     ( stepSeparator steps ) ?
	monthExpr			:: monthSpec   ( stepSeparator steps ) ?
	weekdayExpr			:: weekdaySpec ( stepSeparator steps | positionSeparator position ) ?
                    	
	list				:: expr        ( listSeparator expr ) *
	monthList			:: monthExpr   ( listSeparator monthExpr ) *
	weekdayList			:: weekdayExpr ( listSeparator weekdayExpr ) *
                    	
	yearList			:: list
	dayOfMonthList		:: list
	hoursList			:: list
	minutesList			:: list
	secondsList			:: list
 
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
- (NSNumber*)numberProduction;
- (NSArray*)rangeProduction;
- (NSNumber*)stepsProduction;
- (NSArray*)numspecProduction;
- (APCPointSelector*)exprProductionForType:(UnitType)unitType;
- (APCListSelector*)listProductionForType:(UnitType)unitType;

@end






