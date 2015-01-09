// 
//  APCScheduleExpressionParser.m 
//  AppCore 
// 
//  Copyright (c) 2015 Apple Inc. All rights reserved. 
// 
 
#import "APCScheduleExpressionParser.h"
#import "APCListSelector.h"
#import "APCPointSelector.h"
#import "APCDayOfMonthSelector.h"
#import "APCScheduleExpressionToken.h"
#import "APCScheduleExpressionTokenizer.h"
#import "APCScheduleExpressionToken+DatesAndTimes.h"


static unichar kEndToken				= '\0';
static unichar kListSeparatorToken		= ',';
static unichar kStepSeparatorToken		= '/';
static unichar kPositionSeparatorToken	= '#';
static unichar kWildCardToken			= '*';
static unichar kOtherWildCardToken		= '?';
static unichar kRangeSeparatorToken		= '-';
static unichar kFieldSeparatorToken		= ' ';



// ---------------------------------------------------------
#pragma mark - VarArgs macro
// ---------------------------------------------------------

/**
 Doesn't work.

 Another attempt:
 		va_list args;
		va_start(args, stringOrCharacterSet);
		for (id arg = stringOrCharacterSet; arg != nil; arg = va_arg(args, id))
		{
			[parameters addObject: arg];
		}
		va_end(args);

 based on http://www.cocoawithlove.com/2009/05/variable-argument-lists-in-cocoa.html
 
 but that crashes, too.  :-(
 this isn't core to what I need to do, so...  never mind.
 */
//#define NSArrayFromVariadicArguments( parameterToLeftOfEllipsis )	\
//	({																\
//		NSArray *nsarrayOfVarArgs = nil;							\
//		va_list arguments;											\
//		va_start (arguments, parameterToLeftOfEllipsis);			\
//		nsarrayOfVarArgs = [[NSArray alloc] initWithObjects:		\
//								parameterToLeftOfEllipsis,			\
//								arguments,							\
//								nil];								\
//		va_end (arguments);											\
//																	\
//		/* By mentioning this variable as the last item				\
//		   inside the ({...}), we effectively "return" a value		\
//		   from this macro. */										\
//		nsarrayOfVarArgs;											\
//	})



// ---------------------------------------------------------
#pragma mark - Parser
// ---------------------------------------------------------

@interface APCScheduleExpressionParser ()
@property (nonatomic, strong) NSMutableString*  expression;
@property (nonatomic, assign) BOOL              errorEncountered;
@property (nonatomic, strong) APCScheduleExpressionToken *nextToken;
@property (nonatomic, strong) APCScheduleExpressionTokenizer *tokenizer;
@end


@implementation APCScheduleExpressionParser

- (instancetype) initWithExpression: (NSString*) expression
{
    self = [super init];

    if (self)
    {
        _expression			= [expression mutableCopy];
        _errorEncountered	= NO;
		_nextToken			= nil;
		_tokenizer			= [APCScheduleExpressionTokenizer new];
    }
    
    return self;
}



// ---------------------------------------------------------
#pragma mark - "Preprocessor" methods (being deprecated right now)
// ---------------------------------------------------------

/*
 Before the parser kicks in, we pre-process the string
 to eliminate or convert specific items.
 */

- (void) enforceFiveFields
{
	NSMutableString *newString = nil;

	NSMutableArray *pieces = [[self.expression componentsSeparatedByCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]] mutableCopy];

	if (pieces.count == 7)
	{
		[pieces removeObjectAtIndex: 0];
		[pieces removeLastObject];
		newString = [[pieces componentsJoinedByString: @" "] mutableCopy];
	}

	else if (pieces.count == 5)
	{
		// Happy case.  Ignore.
	}

	else
	{
		// This is an error.  (It isn't happening in practice.)
		NSLog (@"-[APCScheduleParser enforceFiveFields] ERROR: Don't know how to parse an expression with [%d] components.", (int) pieces.count);

		[self recordError];
	}

	if (newString != nil)
	{
		self.expression = newString;
	}
}



// ---------------------------------------------------------
#pragma mark - (mostly) Scanning for Tokens
// ---------------------------------------------------------

- (BOOL)isValidParse
{
    return self.next == kEndToken && self.errorEncountered == NO;
}

//	/**
//	 Writing this method for completeness -- to be compatible
//	 with the character-based scanner -- but I don't yet need it.
//	 */
//	- (BOOL)isValidParse_withTokens
//	{
//		return self.nextToken == nil && self.errorEncountered == NO;
//	}

- (unichar)next
{
    //  Returns the _next_ token or '\0' if no tokens remain. The input stream is not modified.
    unichar nextToken = self.expression.length > 0 ? [self.expression characterAtIndex:0] : 0;
    
    return nextToken;
}

/**
 Returns the next token in the incoming stream, scanning for it
 if not already captured.  Once captured, keeps returning that
 token until -consumeOneToken is called.  This method does NOT
 consume the token (if only to be compatible with the existing
 one-char-per-token code, which performs this "next" concept by
 simply looking at the next char in the incoming stream).
 
 Note that this overrides the standard "get" method for the
 "nextToken" property.  As such, it reads and writes _nextToken.
 */
- (APCScheduleExpressionToken *) nextToken
{
	APCScheduleExpressionToken *token = _nextToken;

	// If we've already scanned for a token, we'll return
	// that.  Otherwise, scan for the next one.
	if (token.countOfScannedCharacters == 0 && self.expression.length > 0)
	{
		token = [self.tokenizer nextTokenFromString: self.expression];

		if (token.didEncounterError)
		{
			NSLog (@"WARNING: %@", token.errorMessage);
			token = nil;
			[self recordError];
		}

		// Record what happened.  This token will be consumed at the next call to -consume.
		_nextToken = token;
	}

	return token;
}

- (void)consumeOneChar
{
    if (self.expression.length > 0)
    {
        [self.expression deleteCharactersInRange:NSMakeRange(0, 1)];
    }
}

- (void) consumeOneToken
{
	if (self.expression.length > 0 && self.nextToken.countOfScannedCharacters > 0)
	{
		NSInteger numCharsToConsume = self.nextToken.countOfScannedCharacters;

		if (numCharsToConsume > self.expression.length)
		{
			NSString *errorMessage = @"-[APCSchedulExpressionParser consumeOneToken] Somehow, we seem to have scanned past the end of the string. How was that possible?";

//			NSAssert (NO, errorMessage);
			NSLog (@"%@", errorMessage);
		}

		else
		{
			NSRange charsToConsume = NSMakeRange (0, numCharsToConsume);
			[self.expression deleteCharactersInRange: charsToConsume];
		}

		// This tells -nextToken to re-scan for the next token.
		[self forgetToken];
	}
}

- (void) forgetToken
{
	self.nextToken = nil;
}

- (void)recordError
{
    self.errorEncountered = YES;
}

- (BOOL)expect:(unichar)c
{
    BOOL    expectation = NO;
    
    if ([self next] == c)
    {
        expectation = YES;
        [self consumeOneChar];
    }
    else
    {
        [self recordError];
    }
    
    return expectation;
}

//	/**
//	 Writing this method for completeness -- to be compatible
//	 with the character-based scanner -- but I don't yet need it.
//	 */
//	- (BOOL) expectToken: (APCScheduleExpressionToken *) token
//	{
//		BOOL expectation = NO;
//
//		if ([self.nextToken isEqual: token])
//		{
//			expectation = YES;
//			[self consumeOneToken];
//		}
//		else
//		{
//			[self recordError];
//		}
//
//		return expectation;
//	}

- (void)fieldSeparatorProduction
{
    while (self.next == kFieldSeparatorToken)
    {
        [self consumeOneChar];
    }
}

- (void) fieldSeparatorProduction_usingTokens
{
	// no need for a while() loop; the scanner already got
	// all tokens considered part of the field separator,
	// i.e., all whitespace
	if (self.nextToken.isFieldSeparator)
	{
		[self consumeOneToken];
	}
	else
	{
		/*
		 This method was called when a field separator
		 was expected.  If we *didn't* get a field separator,
		 we got something *else*.  The next method to ask
		 for a token might not want this -- but no one else
		 has consumed it, yet.  So we'll just pretend
		 we were never here, enabling the next method to
		 make its own decisions.
		 */
		[self forgetToken];
	}
}



// ---------------------------------------------------------
#pragma mark - Production Rules
// ---------------------------------------------------------

- (NSNumber*)numberProduction
{
    NSNumber*       number  = nil;
    NSScanner*      scanner = [NSScanner scannerWithString:self.expression];
    NSCharacterSet* digits  = [NSCharacterSet decimalDigitCharacterSet];
    
    if ([scanner scanUpToCharactersFromSet:digits intoString:NULL] == NO)   //  Check for non-digit characters at head of string
    {
        NSString*   numberString;
        BOOL        foundNumber = [scanner scanCharactersFromSet:digits intoString:&numberString];
        
        if (foundNumber == YES)
        {
            number = [NSNumber numberWithInteger:[numberString integerValue]];
            [self.expression deleteCharactersInRange:NSMakeRange(0, scanner.scanLocation)];
        }
        else
        {
            [self recordError];
        }
    }
    else
    {
        //  Found unexpected non-numeric characters
        [self recordError];
    }
    
    return number;
}

- (NSNumber *) monthProduction  // equiavlent to numberProduction, but for months.
{
	NSInteger month = kAPCScheduleExpressionTokenIntegerValueNotSet;

	/*
	 Scan up to the next month, throw that stuff away, and then
	 scan the month.  This make the scan-by-token code operate
	 the same way as the scan-by-char code.
	 
	 Presumes the string has been advanced to some stuff
	 immediately preceding a month.
	 */
	if (! self.nextToken.canInterpretAsMonth)
	{
		[self consumeOneToken];
	}

	if (self.nextToken.canInterpretAsMonth)
	{
		month = self.nextToken.interpretAsMonth;

		[self consumeOneToken];
	}
	else
	{
		NSLog (@"WARNING:  I was expecting a month, and got something else: [%@].", self.nextToken.stringValue);

		[self recordError];
	}

	return @(month);
}

- (NSNumber *) weekdayProduction  // equiavlent to numberProduction, but for weekdays.
{
	NSInteger weekday = kAPCScheduleExpressionTokenIntegerValueNotSet;

	/*
	 Scan up to the next month, throw that stuff away, and then
	 scan the month.  This make the scan-by-token code operate
	 the same way as the scan-by-char code.

	 Presumes the string has been advanced to some stuff
	 immediately preceding a month.
	 */
	if (! self.nextToken.canInterpretAsWeekday)
	{
		[self consumeOneToken];
	}

	if (self.nextToken.canInterpretAsWeekday)
	{
		weekday = self.nextToken.interpretAsWeekday;
		[self consumeOneToken];
	}
	else
	{
		NSLog (@"WARNING:  I was expecting a weekday, and got something else: [%@].", self.nextToken.stringValue);

		[self recordError];
	}

	return @(weekday);
}

- (NSArray*)rangeProduction
{
	//
	// Production rule:
	//
	//		range :: number ( '-' number ) ?
	//

    NSMutableArray* range = [NSMutableArray array];

    if (isnumber(self.next))
    {
        [range addObject:[self numberProduction]];
        
        if (self.next == kRangeSeparatorToken)
        {
            [self consumeOneChar];
            
            NSNumber*   rangeEnd = [self numberProduction];
            if (rangeEnd != nil)
            {
                [range addObject:rangeEnd];
            }
			else
			{
				// Open-ended range, which is we consider legal.
			}
        }
		else
		{
			// Next token is not part of this range, which is fine.
		}
    }
    else
    {
        [self recordError];
    }
    
    return range;
}

- (NSArray*) monthRangeProduction  // equivalent to rangeProduction, but for months.
{
	//
	// Production rule:
	//
	//		monthRange :: month ( '-' month ) ?
	//

	NSMutableArray* range = [NSMutableArray array];

	if (self.nextToken.canInterpretAsMonth)
	{
		[range addObject: [self monthProduction]];

		if (self.nextToken.isRangeSeparator)
		{
			[self consumeOneToken];

			NSNumber *rangeEnd = [self monthProduction];

			if (rangeEnd != nil)
			{
				// Could this ever happen, given the logic in -monthProduction?
				[range addObject: rangeEnd];
			}
			else
			{
				// Open-ended range, which is legal.
			}
		}
		else
		{
			// Next token is not part of this range, which is fine.
		}
	}
	else
	{
		[self recordError];
	}

	return range;
}

- (NSArray*) weekdayRangeProduction  // equivalent to rangeProduction, but for weekdays.
{
	//
	// Production rule:
	//
	//		weekdayRange :: weekday ( '-' weekday ) ?
	//

	NSMutableArray* range = [NSMutableArray array];

	if (self.nextToken.canInterpretAsWeekday)
	{
		[range addObject: [self weekdayProduction]];

		if (self.nextToken.isRangeSeparator)
		{
			[self consumeOneToken];

			NSNumber *rangeEnd = [self weekdayProduction];

			if (rangeEnd != nil)
			{
				// Could this ever happen, given the logic in -weekdayProduction?
				[range addObject: rangeEnd];
			}
			else
			{
				// Open-ended range, which is legal.
			}
		}
		else
		{
			// Next token is not part of this range, which is fine.
		}
	}
	else
	{
		[self recordError];
	}

	return range;
}

- (NSNumber *) positionProduction
{
	//
	// Production rule:
	//
	//		position :: number
	//

	return [self numberProduction];
}

- (NSNumber*)stepsProduction
{
	//
	// Production rule:
	//
	//		steps :: number
	//
    
    return [self numberProduction];
}

- (NSArray*)numspecProduction
{
	//
	// Production rule:
	//
	//		numspec :: '*' | '?' | range
	//

    NSArray*    numSpec = nil;

    if (self.next == kWildCardToken || self.next == kOtherWildCardToken)
    {
        [self consumeOneChar];
        //  By default, selectors are initialized with min-max values corresponding with the selector's unit type, so it's safe to return nil, here.  Just eat the next token.
    }
    else if (isnumber(self.next) == YES)
    {
        numSpec = [self rangeProduction];
    }
    else
    {
        [self recordError];
    }
    
    return numSpec;
}

- (NSArray*) monthRangeSpecProduction  // equivalent to numspecProduction for months
{
	//
	// Production rule:
	//
	//		monthRangeSpec :: wildcard | monthRange
	//

	NSArray* monthRangeSpec = nil;

	if (self.nextToken.isWildcard)
	{
		[self consumeOneToken];
		//  By default, selectors are initialized with min-max values corresponding with the selector's unit type, so it's safe to return nil, here.  Just eat the next token.
	}
	else if (self.nextToken.canInterpretAsMonth)
	{
		monthRangeSpec = [self monthRangeProduction];
	}
	else
	{
		[self recordError];
	}

	return monthRangeSpec;
}

- (NSArray*) weekdayRangeSpecProduction  // equivalent to numspecProduction for weekdays
{
	//
	// Production rule:
	//
	//		weekdayRangeSpec :: wildcard | weekdayRange
	//

	NSArray* weekdayRangeSpec = nil;

	if (self.nextToken.isWildcard)
	{
		[self consumeOneToken];
		//  By default, selectors are initialized with min-max values corresponding with the selector's unit type, so it's safe to return nil, here.  Just eat the next token.
	}
	else if (self.nextToken.canInterpretAsWeekday)
	{
		weekdayRangeSpec = [self weekdayRangeProduction];
	}
	else
	{
		[self recordError];
	}

	return weekdayRangeSpec;
}

- (APCPointSelector*) exprProductionForType: (UnitType) unitType
{
	//
	// Production rule:
	//
    //		expr :: numspec ( '/' steps | '#' position ) ?
	//

	APCPointSelector *selector = nil;
	NSArray *numSpec = [self numspecProduction];

	if (self.next == kPositionSeparatorToken)
	{
		NSNumber *dayOfWeekToFind = numSpec [0];

		[self consumeOneChar];
		NSNumber *position = [self positionProduction];

		selector = [[APCPointSelector alloc] initWithUnit: unitType
													value: dayOfWeekToFind
												 position: position];
	}

	else
	{
		NSNumber *begin		= numSpec.count > 0 ? numSpec[0] : nil;
		NSNumber *end		= numSpec.count > 1 ? numSpec[1] : nil;
		NSNumber *step		= nil;

		if (self.next == kStepSeparatorToken)
		{
			[self consumeOneChar];
			step = [self stepsProduction];
		}

		selector = [[APCPointSelector alloc] initWithUnit: unitType
											   beginRange: begin
												 endRange: end
													 step: step];
    }

    if (selector == nil)
    {
        [self recordError];
    }
    
    return selector;
}

- (APCPointSelector*) exprProductionForMonth
{
	//
	// Production rule:
	//
	//		monthExpr :: monthRangeSpec ( '/' steps ) ?
	//

	APCPointSelector* selector	= nil;
	NSArray*  monthRangeSpec	= [self monthRangeSpecProduction];
	NSNumber* begin				= monthRangeSpec.count > 0 ? monthRangeSpec[0] : nil;
	NSNumber* end				= monthRangeSpec.count > 1 ? monthRangeSpec[1] : nil;
	NSNumber* step				= nil;

	if (self.nextToken.isStepSeparator)
	{
		[self consumeOneToken];
		step = [self stepsProduction];
	}

	selector = [[APCPointSelector alloc] initWithUnit: kMonth
										   beginRange: begin
											 endRange: end
												 step: step];

	if (selector == nil)
	{
		[self recordError];
	}

	return selector;
}

- (APCPointSelector*) exprProductionForWeekdays
{
	//
	// Production rule:
	//
	//		weekdayExpr :: weekdayRangeSpec ( '/' steps | '#' position ) ?
	//

	APCPointSelector* selector	= nil;
	NSArray*  weekdayRangeSpec	= [self weekdayRangeSpecProduction];
	NSNumber* begin				= weekdayRangeSpec.count > 0 ? weekdayRangeSpec[0] : nil;
	NSNumber* end				= weekdayRangeSpec.count > 1 ? weekdayRangeSpec[1] : nil;
	NSNumber* step				= nil;

	if (self.nextToken.isPositionSeparator)
	{
		[self consumeOneToken];

		NSNumber *position = [self positionProduction];

		selector = [[APCPointSelector alloc] initWithUnit: kDayOfWeek
													value: begin
												 position: position];
	}

	else
	{
		if (self.nextToken.isStepSeparator)
		{
			[self consumeOneToken];
			step = [self stepsProduction];
		}

		selector = [[APCPointSelector alloc] initWithUnit: kDayOfWeek
											   beginRange: begin
												 endRange: end
													 step: step];
	}

	if (selector == nil)
	{
		[self recordError];
	}

	return selector;
}

- (APCListSelector*)listProductionForType:(UnitType)unitType
{
	//
	// Production rule:
	//
	//		genericList :: genericExpr ( ',' genericExpr) *
	//

    NSMutableArray*     subSelectors = [NSMutableArray array];
    APCListSelector*    listSelector = nil;
    
    while (self.next != kEndToken && self.next != kFieldSeparatorToken)
    {
        APCPointSelector*   pointSelector = [self exprProductionForType:unitType];
        
        if (self.errorEncountered)
        {
            goto parseError;
        }
        else
        {
            [subSelectors addObject:pointSelector];
            
            if (self.next == kListSeparatorToken)
            {
                [self consumeOneChar];
            }
            else if (self.next != kEndToken && self.next != kFieldSeparatorToken)
            {
                [self recordError];
            }
			else
			{
				// End of the string, or end of the list of <unitType>.
				// We'll exit the loop in a moment.
			}
        }
    }
    
    listSelector = [[APCListSelector alloc] initWithSubSelectors:subSelectors];
    
parseError:
    return listSelector;
}

- (APCListSelector*) listProductionForMonthList
{
	//
	// Production rule:
	//
	//		monthList :: monthExpr (',' monthExpr) *
	//

	NSMutableArray*  subSelectors = [NSMutableArray array];
	APCListSelector* listSelector = nil;

	while (self.nextToken != nil && ! self.nextToken.isFieldSeparator)
	{
		APCPointSelector* pointSelector = [self exprProductionForMonth];

		if (self.errorEncountered)
		{
			goto parseError;
		}
		else
		{
			[subSelectors addObject:pointSelector];

			if (self.nextToken.isListSeparator)
			{
				[self consumeOneToken];
			}
			else if (self.nextToken != nil && ! self.nextToken.isFieldSeparator)
			{
				[self recordError];
			}
			else
			{
				// End of the string, or end of the list of months.
				// We'll exit the loop in a moment.
			}
		}
	}

	listSelector = [[APCListSelector alloc] initWithSubSelectors:subSelectors];

parseError:
	return listSelector;
}

- (APCListSelector*) listProductionForWeekdayList
{
	//
	// Production rule:
	//
	//		weekdayList :: weekdayExpr (',' weekdayExpr) *
	//

	NSMutableArray*  subSelectors = [NSMutableArray array];
	APCListSelector* listSelector = nil;

	while (self.nextToken != nil && ! self.nextToken.isFieldSeparator)
	{
		APCPointSelector* pointSelector = [self exprProductionForWeekdays];

		if (self.errorEncountered)
		{
			goto parseError;
		}
		else
		{
			[subSelectors addObject:pointSelector];

			if (self.nextToken.isListSeparator)
			{
				[self consumeOneToken];
			}
			else if (self.nextToken != nil && ! self.nextToken.isFieldSeparator)
			{
				[self recordError];
			}
			else
			{
				// End of the string, or end of the list of weekdays.
				// We'll exit the loop in a moment.
			}
		}
	}

	listSelector = [[APCListSelector alloc] initWithSubSelectors:subSelectors];

parseError:
	return listSelector;
}

- (APCListSelector*)yearProduction:(UnitType)unitType
{
    //  The parser doesn't currently support Year products but a default selector is provided to help
    //  rollover from year to year.
    //  Defaulting to a wildcard selector
    APCPointSelector*   pointSelector = [[APCPointSelector alloc] initWithUnit:unitType beginRange:nil endRange:nil step:nil];
    APCListSelector*    listSelector  = [[APCListSelector alloc] initWithSubSelectors:@[pointSelector]];
    
    return listSelector;
}




// ---------------------------------------------------------
#pragma mark - Extract all fields (conceptual "main()" for this file)
// ---------------------------------------------------------

- (void)fieldsProduction
{
	//
	// Production rule:
	//
	//		fields :: minutesList hoursList dayOfMonthList monthList dayOfWeekList
	//

	APCListSelector* rawDayOfMonthSelector = nil;
	APCListSelector* rawDayOfWeekSelector = nil;


	//
	// Remove any leading spaces.
	//

	[self fieldSeparatorProduction_usingTokens];



	//
	// Extract minutes.
	//
    
    self.minuteSelector = [self listProductionForType:kMinutes];

    if (self.errorEncountered)
    {
        NSLog(@"Invalid Minute selector");
        goto parseError;
    }
    

	//
	// Extract hours.
	//

    [self fieldSeparatorProduction];

    self.hourSelector = [self listProductionForType:kHours];

    if (self.errorEncountered)
    {
        NSLog(@"Invalid Hour selector");
        goto parseError;
    }
    

	//
	// Extract days of the month.
	//

    [self fieldSeparatorProduction];

	rawDayOfMonthSelector = [self listProductionForType:kDayOfMonth];

    if (self.errorEncountered)
    {
        NSLog(@"Invalid Day of Month selector");
        goto parseError;
    }


	//
	// Extract months.
	//

    [self fieldSeparatorProduction_usingTokens];
    
    self.monthSelector = [self listProductionForMonthList];

    if (self.errorEncountered)
    {
        NSLog(@"Invalid Month selector");
        goto parseError;
    }
    

	//
	// Extract days of the week.
	//

    [self fieldSeparatorProduction_usingTokens];

	rawDayOfWeekSelector = [self listProductionForWeekdayList];
    if (self.errorEncountered)
    {
        NSLog(@"Invalid Day of Week selector");
        goto parseError;
    }
    

	//
	// Ignore everything else.
	// Generate a "*" for the Year field.
	//

    self.yearSelector = [self yearProduction:kYear];


	//
	// Now that we know there are no errors:  create a
	// wrapper around the day-of-month and day-of-week
	// selector we just generated.
	//

	self.dayOfMonthSelector = [[APCDayOfMonthSelector alloc] initWithFreshlyParsedDayOfMonthSelector: rawDayOfMonthSelector andDayOfWeekSelector: rawDayOfWeekSelector];


	//
	// Bug out.
	//

parseError:
    return;
}

- (BOOL)parse
{
	/*
	 Sometimes, the field list has SEVEN fields:  seconds on the left,
	 years on the right.  In practice, we ignore those:  "minutes" is
	 plenty of resolution, and we work in 3-day-increments, not years.
	 So strip those fields.
	 */
//	[self enforceFiveFields];


	// Ok.  Parse it.
    [self fieldsProduction];
    
    return !self.errorEncountered;
}

@end
