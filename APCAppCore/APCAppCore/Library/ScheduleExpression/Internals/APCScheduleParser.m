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


static unichar kEndToken            = '\0';
static unichar kListSeparatorToken  = ',';
static unichar kStepSeparatorToken  = '/';
static unichar kWildCardToken       = '*';
static unichar kOtherWildCardToken  = '?';
static unichar kRangeSeparatorToken = '-';
static unichar kFieldSeparatorToken = ' ';


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

- (APCPointSelector*)exprProductionForType:(UnitType)unitType
{
	//
	// Production rule:
	//
    //		expr :: numspec ( '/' steps ) ?
	//

    NSArray*            numSpec  = [self numspecProduction];
    NSNumber*           step     = nil;
    
    if (self.next == kStepSeparatorToken)
    {
        [self consumeOneChar];
        step = [self stepsProduction];
    }

    NSNumber*           begin    = numSpec.count > 0 ? numSpec[0] : nil;
    NSNumber*           end      = numSpec.count > 1 ? numSpec[1] : nil;

	/*
	 Ron:  this is where the "point selector" -- the date range generator -- gets created.
	 */
	
    APCPointSelector*   selector = [[APCPointSelector alloc] initWithUnit:unitType
															   beginRange:begin
																 endRange:end
																	 step:step];
    
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

		//
		// Ron:  about to follow dayOfMonth production through here...
		//

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
	//		fields :: relatvie minutesList hoursList dayOfMonthList monthList dayOfWeekList
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
    [self fieldsProduction];
    
    return !self.errorEncountered;
}

@end
