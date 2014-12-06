// 
//  APCScheduleParser.h 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import <Foundation/Foundation.h>
#import "APCListSelector.h"
#import "APCPointSelector.h"

/*
 Ron:  Ed says:  This the parser grammar.  Precedence
 matters:  Higher in the list means higher precedence
 in the parser.
 
 For example, reading from bottom to top:
 - lists (rule 2)...
 - ...can contain ranges (rule 5)...
 - ...which might contain steps (rule 6)...
 - which probably contain digits (rule 9).
 
 There's nothing automatic about this.  We manually
 call functions to perform each of these rules in the
 appropriate places.  I.e., we've hand-written a parser
 that implements these rules.
 
 Current version:
	10.	digit		:: '0'..'9'
	9.	dow			:: 'a'..'z'
	8.	number		:: digit+ | dow+
	7.	position	:: number
	6.	steps		:: number
	5.	range		:: number ( '-' number ) ?
	4.	numspec		:: '*' | '?' | range
	3.	expr		:: numspec ( '/' steps | '#' position ) ?
	2.	list		:: expr ( ',' expr ) *
	1.	fields		:: minutesList hoursList dayOfMonthList monthList dayOfWeekList

 Thinking about the more complex, upcoming one:
 	x.	digit			::	[0-9]
 	x.	letter			::	[a-zA-Z]
 	x.	nameOfMonth		::	letter{3}
 	x.	dayOfWeek		::	letter{3}
 	x.	number			::	digit+
 	x.	nameOrNumber	::	number | dayOfWeek | nameOfMonth
 	x.	steps			::	number
 	x.	range			::	nameOrNumber ( '-' nameOrNumber ) ?
 	x.	rangeSpec		::	'*' | '?' | range
 	x.	rangeWithSteps	::	rangeSpec ( '/' steps ) ?
 	x.	nthInstance		::	nameOrNumber '#' number
 	x.	expr			::	rangeWithSteps | nthInstance
 	x.	list			::	expr ( ',' expr ) *
 	x.	whitespace		::	[\s\t\r\n]+
 	x.	years			::	list
 	x.	daysOfWeek		::	list
 	x.	months			::	list
 	x.	daysOfMonth		::	list
 	x.	hours			::	list
 	x.	minutes			::	list
 	x.	seconds			::	list
 	x.	fields			::	seconds whitespace minutes whitespace	\
 								hours whitespace daysOfMonth whitespace	\
 								months whitespace daysOfWeek whitespace years
 */

@interface APCScheduleParser : NSObject

@property (nonatomic, strong) APCTimeSelector*    minuteSelector;
@property (nonatomic, strong) APCTimeSelector*    hourSelector;
@property (nonatomic, strong) APCTimeSelector*    dayOfMonthSelector;
@property (nonatomic, strong) APCTimeSelector*    monthSelector;
@property (nonatomic, strong) APCTimeSelector*    yearSelector;
@property (nonatomic, assign) BOOL                isRelative;

- (instancetype)initWithExpression:(NSString*)expression;

/**
 *  The validity of the parsed expression.
 *
 *  @return Returns a _YES_ value if the parse is at the _end_ and no errors have been encountered.
 */
- (BOOL)isValidParse;

- (BOOL)parse;


/*
 Private, but we sometimes call these from the test haress.
 So, um, please don't use these.
 */
- (NSNumber*)numberProduction;
- (NSArray*)rangeProduction;
- (NSNumber*)stepsProduction;
- (NSArray*)numspecProduction;
- (APCPointSelector*)exprProductionForType:(UnitType)unitType;
- (APCListSelector*)listProductionForType:(UnitType)unitType;

@end






