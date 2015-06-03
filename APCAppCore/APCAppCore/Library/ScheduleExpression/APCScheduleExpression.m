// 
//  APCScheduleExpression.m 
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

- (APCScheduleEnumerator*)enumeratorBeginningAtTime:(NSDate*)start
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

- (APCScheduleEnumerator*)enumeratorBeginningAtTime:(NSDate*)start endingAtTime:(NSDate*)end
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










