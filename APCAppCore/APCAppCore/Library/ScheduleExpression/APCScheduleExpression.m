// 
//  APCScheduleExpression.m 
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//
 
#import "APCScheduleExpression.h"
#import "APCScheduleExpressionParser.h"
#import "APCTimeSelectorEnumerator.h"
#import "APCScheduleEnumerator.h"


@interface APCScheduleExpression ()

@property (nonatomic, strong) NSString*                     originalCronExpression;
@property (nonatomic, strong) NSArray*						selectors;
@property (nonatomic, assign) BOOL							validExpression;
@property (nonatomic, strong) APCTimeSelector*				minuteSelector;
@property (nonatomic, strong) APCTimeSelector*				dayOfMonthSelector;
@property (nonatomic, strong) APCTimeSelector*				hourSelector;
@property (nonatomic, strong) APCTimeSelector*				monthSelector;
@property (nonatomic, strong) APCTimeSelector*				yearSelector;

@end


@implementation APCScheduleExpression

- (instancetype)initWithExpression:(NSString*)expression timeZero:(NSTimeInterval) __unused timeZero
{
    self = [self init];
	
    if (self)
    {
        _originalCronExpression = expression;

        APCScheduleExpressionParser* parser = [[APCScheduleExpressionParser alloc] initWithExpression:expression];
        
        _validExpression = [parser parse];
        
        if (_validExpression)
        {
            _minuteSelector     = parser.minuteSelector;
            _hourSelector       = parser.hourSelector;
            _dayOfMonthSelector = parser.dayOfMonthSelector;
            _monthSelector      = parser.monthSelector;
            _yearSelector       = parser.yearSelector;
        }

		else
		{
			NSLog (@"[APCScheduleExpression initWithExpression:timeZero:] ERROR: Received invalid cron expression [%@].  Returning 'nil' for the ScheduleExpression.", expression);

			self = nil;
		}
    }
    
    return self;
}

- (NSEnumerator*)enumeratorBeginningAtTime:(NSDate*)start
{
    NSParameterAssert(start != nil);
    
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
    NSParameterAssert(start != nil);
    NSParameterAssert(end != nil);
    
    return [[APCScheduleEnumerator alloc] initWithBeginningTime:start
                                                     endingTime:end
                                                 minuteSelector:self.minuteSelector
                                                   hourSelector:self.hourSelector
                                             dayOfMonthSelector:self.dayOfMonthSelector
                                                  monthSelector:self.monthSelector
                                                   yearSelector:self.yearSelector
                                         originalCronExpression:self.originalCronExpression];
}


@end










