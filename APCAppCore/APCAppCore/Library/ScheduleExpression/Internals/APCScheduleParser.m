// 
//  APCScheduleParser.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "APCScheduleParser.h"
#import "APCListSelector.h"
#import "APCPointSelector.h"
#import "APCDayOfMonthSelector.h"


static unichar kEndToken				= '\0';
static unichar kListSeparatorToken		= ',';
static unichar kStepSeparatorToken		= '/';
static unichar kPositionSeparatorToken	= '#';
static unichar kWildCardToken			= '*';
static unichar kOtherWildCardToken		= '?';
static unichar kRangeSeparatorToken		= '-';
static unichar kFieldSeparatorToken		= ' ';


@interface APCScheduleParser ()

@property (nonatomic, strong) NSMutableString*  expression;
@property (nonatomic, assign) BOOL              errorEncountered;

@end


@implementation APCScheduleParser

- (instancetype)initWithExpression:(NSString*)expression
{
    self = [super init];
    if (self)
    {
        _expression       = [expression mutableCopy];
        _errorEncountered = NO;
    }
    
    return self;
}



// ---------------------------------------------------------
#pragma mark - "Preprocessor" methods
// ---------------------------------------------------------

/*
 Before the parser kicks in, we pre-process the string
 to eliminate or convert specific items.
 */

- (void) trimAndNormalizeSpaces
{
	NSMutableString *newString = self.expression.mutableCopy;

	[newString replaceOccurrencesOfString: @"\\s+"
							   withString: @" "
								  options: NSRegularExpressionSearch
									range: NSMakeRange (0, newString.length)];

	newString = [[newString stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]] mutableCopy];

	self.expression = newString;
}

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

- (void) convertDayAndMonthNamesToNumbers
{
	NSMutableString *newString = self.expression.mutableCopy;

	// We'll do a case-insensitive search.
	NSDictionary *stringsToReplace = @{
									   @"sun": @0,
									   @"mon": @1,
									   @"tue": @2,
									   @"wed": @3,
									   @"thu": @4,
									   @"fri": @5,
									   @"sat": @6,

									   @"jan": @1,
									   @"feb": @2,
									   @"mar": @3,
									   @"apr": @4,
									   @"may": @5,
									   @"jun": @6,
									   @"jul": @7,
									   @"aug": @8,
									   @"sep": @9,
									   @"oct": @10,
									   @"nov": @11,
									   @"dec": @12,
									   };

	for (NSString *monthOrWeekday in stringsToReplace.allKeys)
	{
		NSNumber *number = stringsToReplace [monthOrWeekday];
		NSString *digit = number.stringValue;

		[newString replaceOccurrencesOfString: monthOrWeekday
								   withString: digit
									  options: NSCaseInsensitiveSearch
										range: NSMakeRange(0, newString.length)];
	}

	self.expression = newString;
}



// ---------------------------------------------------------
#pragma mark - The Parser
// ---------------------------------------------------------

- (BOOL)isValidParse
{
    return self.next == kEndToken && self.errorEncountered == NO;
}

- (unichar)next
{
    //  Returns the _next_ token or '\0' if no tokens remain. The input stream is not modified.
    unichar nextToken = self.expression.length > 0 ? [self.expression characterAtIndex:0] : 0;
    
    return nextToken;
}

- (void)consumeOneChar
{
    if (self.expression.length > 0)
    {
        [self.expression deleteCharactersInRange:NSMakeRange(0, 1)];
    }
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

- (void)fieldSeparatorProduction
{
    while (self.next == kFieldSeparatorToken)
    {
        [self consumeOneChar];
    }
}

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
        //  By defaults, selectors are initialized with min-max values corresponding with the selector's unit type
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

- (APCListSelector*)listProductionForType:(UnitType)unitType
{
	//
	// Production rule:
	//
	//		list :: expr ( ',' expr ) *
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

- (void)fieldsProduction
{
	//
	// Production rule:
	//
	//		fields :: minutesList hoursList dayOfMonthList monthList dayOfWeekList
	//

	APCListSelector* rawDayOfMonthSelector = nil;
	APCListSelector* rawDayOfWeekSelector = nil;
    
    self.minuteSelector = [self listProductionForType:kMinutes];
    if (self.errorEncountered)
    {
        NSLog(@"Invalid Minute selector");
        goto parseError;
    }
    
    [self fieldSeparatorProduction];
    
    
    self.hourSelector = [self listProductionForType:kHours];
    if (self.errorEncountered)
    {
        NSLog(@"Invalid Hour selector");
        goto parseError;
    }
    
    [self fieldSeparatorProduction];

	rawDayOfMonthSelector = [self listProductionForType:kDayOfMonth];
    if (self.errorEncountered)
    {
        NSLog(@"Invalid Day of Month selector");
        goto parseError;
    }
    
    [self fieldSeparatorProduction];
    
    self.monthSelector = [self listProductionForType:kMonth];
    if (self.errorEncountered)
    {
        NSLog(@"Invalid Month selector");
        goto parseError;
    }
    
    [self fieldSeparatorProduction];

	rawDayOfWeekSelector = [self listProductionForType:kDayOfWeek];
    if (self.errorEncountered)
    {
        NSLog(@"Invalid Day of Week selector");
        goto parseError;
    }
    
    [self expect: kEndToken];
    
    self.yearSelector = [self yearProduction:kYear];


	/*
	 Now that we know there are no errors:  create a
	 wrapper around the day-of-month and day-of-week
	 selector we just generated.
	 */
	self.dayOfMonthSelector = [[APCDayOfMonthSelector alloc] initWithFreshlyParsedDayOfMonthSelector: rawDayOfMonthSelector andDayOfWeekSelector: rawDayOfWeekSelector];

parseError:
    return;
}

- (BOOL)parse
{
	[self trimAndNormalizeSpaces];

	/*
	 Sometimes, the field list has SEVEN fields:  seconds on the left,
	 years on the right.  In practice, we ignore those:  "minutes" is
	 plenty of resolution, and we work in 3-day-increments, not years.
	 So strip those fields.
	 */
	[self enforceFiveFields];


	/*
	 Convert days of months and weekdays to their numeric
	 equivalents.
	 */
	[self convertDayAndMonthNamesToNumbers];


	// Ok.  Parse it.
    [self fieldsProduction];
    
    return !self.errorEncountered;
}

@end
