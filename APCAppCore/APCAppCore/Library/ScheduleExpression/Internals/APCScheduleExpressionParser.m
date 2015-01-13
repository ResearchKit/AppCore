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
@property (nonatomic, strong) NSMutableString* expression;
@property (nonatomic, strong) NSString* originalExpression;
@property (nonatomic, assign) BOOL errorEncountered;
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
		_originalExpression = expression;
        _errorEncountered	= NO;
		_nextToken			= nil;
		_tokenizer			= [APCScheduleExpressionTokenizer new];
    }
    
    return self;
}



// ---------------------------------------------------------
#pragma mark - (mostly) Scanning for Tokens
// ---------------------------------------------------------

- (BOOL)isValidParse
{
    return self.nextToken == nil && self.errorEncountered == NO;
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

- (void) fieldSeparatorProduction
{
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
    NSNumber* number = nil;

	if (self.nextToken.isNumber)
	{
		number = @(self.nextToken.integerValue);
		[self consumeOneToken];
	}
    else
    {
        //  Found unexpected non-numeric characters
        [self recordError];
    }
    
    return number;
}

- (NSArray*)rangeProduction
{
	//
	// Production rule:
	//
	//		range :: item ( rangeSeparator item ) ?
	//

    NSMutableArray* range = [NSMutableArray array];

	if (self.nextToken.isNumber)
    {
		NSInteger rangeStart = self.nextToken.integerValue;
		[range addObject: @(rangeStart)];
		[self consumeOneToken];

        if (self.nextToken.isRangeSeparator)
        {
            [self consumeOneToken];

			if (self.nextToken.isNumber)
			{
				NSInteger rangeEnd = self.nextToken.integerValue;
				[range addObject: @(rangeEnd)];

				[self consumeOneToken];
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

- (NSArray*) rangeSpecProduction
{
	//
	// Production rule:
	//
	//		rangeSpec :: '*' | '?' | range
	//

    NSArray* rangeSpec = nil;

    if (self.nextToken.isWildcard)
    {
		/*
		 By default, selectors are initialized with min-max
		 values corresponding to the selector's unit type,
		 so it's safe to return nil, here.  Just eat the
		 next token.
		 */
        [self consumeOneToken];
    }

	else
	{
		// RangeProduction will raise an error
		// if the next thing encountered isn't legal.
		rangeSpec = [self rangeProduction];
	}
    
    return rangeSpec;
}

- (APCPointSelector*) expressionProduction
{
	//
	// Production rule:
	//
    //		expression :: rangeSpec ( '/' steps | '#' position ) ?
	//

	APCPointSelector *selector = nil;
	NSArray *rangeSpec = [self rangeSpecProduction];

	if (self.nextToken.isPositionSeparator)
	{
		[self consumeOneToken];

		NSNumber *position = [self positionProduction];

		NSNumber *dayOfWeekToFind = rangeSpec [0];
		selector = [[APCPointSelector alloc] initWithValue: dayOfWeekToFind
												  position: position];
	}

	else  // either: (a) stepSeparator or (b) not-in-this-expression
	{
		NSNumber *begin	= rangeSpec.count > 0 ? rangeSpec[0] : nil;
		NSNumber *end	= rangeSpec.count > 1 ? rangeSpec[1] : nil;
		NSNumber *step	= nil;

		if (self.nextToken.isStepSeparator)
		{
			[self consumeOneToken];

			step = [self stepsProduction];
		}

		selector = [[APCPointSelector alloc] initWithRangeStart: begin
													   rangeEnd: end
														   step: step];
    }

    if (selector == nil)
    {
        [self recordError];
    }
    
    return selector;
}

- (APCListSelector*) listProduction
{
	//
	// Production rule:
	//
	//		genericList :: genericExpr ( ',' genericExpr) *
	//

    NSMutableArray*  subSelectors = [NSMutableArray array];
    APCListSelector* listSelector = nil;

	while (self.nextToken != nil && ! self.nextToken.isFieldSeparator)
    {
        APCPointSelector* pointSelector = [self expressionProduction];
        
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
//			else if (self.nextToken != nil && ! self.nextToken.isFieldSeparator)
//			{
//				[self recordError];
//			}
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

- (APCListSelector*)yearProduction
{
    /*
	 The parser doesn't currently support Year products.
	 However, we'll provide a year selector with default
	 settings, so we can roll over from year to year.
	 */
    APCPointSelector* pointSelector = [[APCPointSelector alloc] initWithRangeStart: nil
																		  rangeEnd: nil
																			  step: nil];
	pointSelector.unitType = kYear;

    APCListSelector* listSelector = [[APCListSelector alloc] initWithSubSelectors:@[pointSelector]];
    
    return listSelector;
}




// ---------------------------------------------------------
#pragma mark - Set date/time ranges for the selectors we parsed
// ---------------------------------------------------------

- (void) coerceSelector: (APCListSelector *) list
			   intoType: (UnitType) type
{
	for (APCPointSelector *point in list.subSelectors)
	{
		point.unitType = type;
	}
}

/**
 Because -nextToken scans for a new token,
 we can't use the debugger to inspect that *property*
 without messing up the logic in the code.  (...which
 may mean I can't make -nextToken generate a new
 token.)  This method returns the ivars I need to
 inspect.
 */
- (id) debugHelper
{
	NSMutableDictionary* stuff = [NSMutableDictionary new];

	id nextToken = (_nextToken == nil ? [NSNull null] : _nextToken);
	id expression = _expression;

	stuff [@"nextToken"] = nextToken;
	stuff [@"nextToken.description"] = [nextToken description];
	stuff [@"expression"] = expression;
	stuff [@"originalExpression"] = self.originalExpression;

	return stuff;
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

	NSMutableArray* incomingSelectors = [NSMutableArray new];
	APCListSelector* thisSelector = nil;

	[self fieldSeparatorProduction];

	// Slurp in all selectors.  We'll assume they're in
	// the right order.  We'll set type-specific time/date
	// limits afterwards, once we know which selector
	// is which.
	while (self.nextToken)
	{
		thisSelector = [self listProduction];

		if (self.errorEncountered)
		{
			NSAssert (NO, @"You should probably print something useful, here.");
			break;
		}

		else
		{
			[incomingSelectors addObject: thisSelector];

			[self fieldSeparatorProduction];
		}
	}

	if (! self.errorEncountered)
	{
		// If we have "seconds" and/or "years," remove "seconds."
		// We'll ignore "years."
		if (incomingSelectors.count > 5)
		{
			[incomingSelectors removeObjectAtIndex: 0];
		}

		APCListSelector* maybeMinuteSelector	= incomingSelectors [0];
		APCListSelector* maybeHourSelector		= incomingSelectors [1];
		APCListSelector* maybeDaySelector		= incomingSelectors [2];
		APCListSelector* maybeMonthSelector		= incomingSelectors [3];
		APCListSelector* maybeWeekdaySelector	= incomingSelectors [4];
		APCListSelector* maybeYearSelector		= [self yearProduction];

		// Set their types.  This blatantly ignores whether they
		// might contain special characters for the wrong type.
		[self coerceSelector: maybeMinuteSelector	intoType: kMinutes];
		[self coerceSelector: maybeHourSelector		intoType: kHours];
		[self coerceSelector: maybeDaySelector		intoType: kDayOfMonth];
		[self coerceSelector: maybeMonthSelector	intoType: kMonth];
		[self coerceSelector: maybeWeekdaySelector	intoType: kDayOfWeek];

		if (! self.errorEncountered)
		{
			self.minuteSelector	= maybeMinuteSelector;
			self.hourSelector	= maybeHourSelector;
			self.monthSelector	= maybeMonthSelector;
			self.yearSelector	= maybeYearSelector;

			self.dayOfMonthSelector = [[APCDayOfMonthSelector alloc] initWithFreshlyParsedDayOfMonthSelector: maybeDaySelector andDayOfWeekSelector: maybeWeekdaySelector];
		}
	}
}

- (BOOL)parse
{
    [self fieldsProduction];
    
    return !self.errorEncountered;
}

@end












