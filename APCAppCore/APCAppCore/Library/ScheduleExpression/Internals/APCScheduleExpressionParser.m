// 
//  APCScheduleExpressionParser.m 
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
 
#import "APCScheduleExpressionParser.h"
#import "APCListSelector.h"
#import "APCPointSelector.h"
#import "APCDayOfMonthSelector.h"
#import "APCScheduleExpressionToken.h"
#import "APCScheduleExpressionTokenizer.h"
#import "APCLog.h"



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
		NSUInteger numCharsToConsume = self.nextToken.countOfScannedCharacters;

		if (numCharsToConsume > self.expression.length)
		{
			NSString *errorMessage = @"-[APCSchedulExpressionParser consumeOneToken] Somehow, we seem to have scanned past the end of the string. How was that possible?";

			// During development:  NSAssert (NO, errorMessage);
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

        // Validate and optionally coerce the data for various types.
        switch (type)
        {
            case kDayOfWeek:
                [self coercePointSelectorIntoDaysOfWeek: point];
                break;
                
            default:
                // No changes for the rest of them, yet.
                break;
        }
	}
}

/**
 TODO:  This would be better in a custom subclass, such as
 something like APCWeekdaySelector.
 */
- (void) coercePointSelectorIntoDaysOfWeek: (APCPointSelector *) soonToBeWeekSelector
{
    // One very special edge case we're looking for:  a "7" passed for "Sunday."
    if (soonToBeWeekSelector.begin.integerValue == 7) { soonToBeWeekSelector.begin = @(0); }
    if (soonToBeWeekSelector.end.integerValue == 7) { soonToBeWeekSelector.end = @(0); }
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
			NSLog (@"WARNING: Something broke during the parsing process.  Returning nil for the ScheduleExpression.");
			break;
		}

		else
		{
			[incomingSelectors addObject: thisSelector];

			[self fieldSeparatorProduction];
		}
	}

	// Problem in the incoming expression.
	if (incomingSelectors.count < 5)
	{
		/*
		 Thanks to http://nshipster.com/nserror/ for help in constructing this.
		 */
		NSString* errorMessage = [NSString stringWithFormat: @"Couldn't identify five fields (minutes, hours, days, months, weekdays) in the cron string [%@]. Returning nil for the ScheduleExpression.", self.originalExpression];

		NSError *error = [NSError errorWithDomain: @"APCScheduleParser"
											 code: -1
										 userInfo: @{ NSLocalizedDescriptionKey: errorMessage }];

		APCLogError2 (error);

		[self recordError];
	}

	// If more than 5 fields, we'll assume the 1st field is
	// seconds, assume the next 5 are the ones we expect,
	// and ignore anything after that.
	else if (incomingSelectors.count > 5)
	{
		[incomingSelectors removeObjectAtIndex: 0];
	}

	if (! self.errorEncountered)
	{
		// If we have "seconds" and/or "years," remove "seconds."
		// We'll ignore "years."
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












