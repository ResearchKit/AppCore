//
//  APCScheduleExpression.m
//  Schedule
//
//  Created by Edward Cessna on 9/15/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCScheduleExpression.h"
#import "APCScheduleParser.h"
#import "APCTimeSelectorEnumerator.h"
#import "APCScheduleEnumerator.h"


@interface APCScheduleExpression ()

@property (nonatomic, strong) APCScheduleParser*    parser;
@property (nonatomic, strong) NSArray*              selectors;
@property (nonatomic, strong) NSString*				originalCronExpression;

@property (nonatomic, assign) BOOL                  validExpression;
@property (nonatomic, strong) APCTimeSelector*      minuteSelector;
@property (nonatomic, strong) APCTimeSelector*      dayOfMonthSelector;
@property (nonatomic, strong) APCTimeSelector*      hourSelector;
@property (nonatomic, strong) APCTimeSelector*      monthSelector;
@property (nonatomic, strong) APCTimeSelector*      yearSelector;

@end


@implementation APCScheduleExpression

- (instancetype)initWithExpression:(NSString*)expression timeZero:(NSTimeInterval)timeZero
{
    self = [self init];
    if (self)
    {
		self.originalCronExpression = expression;		// debugging only --ron
		
        APCScheduleParser* parser = [[APCScheduleParser alloc] initWithExpression:expression];
        
        _validExpression = [parser parse];
        
        if (_validExpression)
        {
			/*
			 Ron: (1) Why not just remember the parser, instead of remembering the individual components?
			 */
			
            _minuteSelector     = parser.minuteSelector;
            _hourSelector       = parser.hourSelector;
            _dayOfMonthSelector = parser.dayOfMonthSelector;
            _monthSelector      = parser.monthSelector;
            _yearSelector       = parser.yearSelector;
        }
    }
    
    return self;
}

- (BOOL)isValid
{
    return self.parser.isValidParse;
}

- (NSEnumerator*)enumeratorBeginningAtTime:(NSDate*)start
{
    return [[APCScheduleEnumerator alloc] initWithBeginningTime:start
                                                 minuteSelector:self.minuteSelector
                                                   hourSelector:self.hourSelector
                                             dayOfMonthSelector:self.dayOfMonthSelector
                                                  monthSelector:self.monthSelector
												   yearSelector:self.yearSelector
										 originalCronExpression:self.originalCronExpression];
}

- (NSEnumerator*)enumeratorBeginningAtTime:(NSDate*)start endingAtTime:(NSDate*)end
{
    return [[APCScheduleEnumerator alloc] initWithBeginningTime:start
                                                     endingTime:end
                                                 minuteSelector:self.minuteSelector
                                                   hourSelector:self.hourSelector
                                             dayOfMonthSelector:self.dayOfMonthSelector
                                                  monthSelector:self.monthSelector
												   yearSelector:self.yearSelector
										 originalCronExpression:self.originalCronExpression];
}

//	- (void) recomputeDaysAfterRollingOverMonthOrYearInEnumerator: (id) scheduleEnumerator
//	{
//		if ([scheduleEnumerator isKindOfClass: [APCScheduleEnumerator class]])
//		{
//			APCScheduleEnumerator *enumerator = (APCScheduleEnumerator *) scheduleEnumerator;
//	
//			[enumerator recomputeDaysAfterRollingOverMonthOrYear];
//		}
//	}


- (NSString *) description
{
	return [NSString stringWithFormat: @"%@ 0x%x [%@]",
			NSStringFromClass([self class]),
			(unsigned int) self,
			self.originalCronExpression];
}

- (NSString *) debugDescription
{
	return self.description;
}

@end










