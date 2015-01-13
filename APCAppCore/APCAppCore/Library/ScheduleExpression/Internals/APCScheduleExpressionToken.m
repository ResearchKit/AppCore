//
//  APCScheduleExpressionToken.m
//  AppCore
//
//  Copyright (c) 2015 Apple Inc. All rights reserved.
//

#import "APCScheduleExpressionToken.h"


@implementation APCScheduleExpressionToken

- (id) init
{
	self = [super init];

	if (self)
	{
		_integerValue = kAPCScheduleExpressionTokenIntegerValueNotSet;
		_stringValue = nil;
		_countOfScannedCharacters = 0;
		_type = APCScheduleExpressionTokenTypeNotYetParsed;
		_didEncounterError = NO;
		_errorMessage = nil;
	}

	return self;
}

// Stuff that worked.
- (BOOL) isWord					{ return self.type == APCScheduleExpressionTokenTypeWord; }
- (BOOL) isNumber				{ return self.type == APCScheduleExpressionTokenTypeNumber; }
- (BOOL) isWildcard				{ return self.type == APCScheduleExpressionTokenTypeWildcard; }
- (BOOL) isListSeparator		{ return self.type == APCScheduleExpressionTokenTypeListSeparator; }
- (BOOL) isStepSeparator		{ return self.type == APCScheduleExpressionTokenTypeStepSeparator; }
- (BOOL) isFieldSeparator		{ return self.type == APCScheduleExpressionTokenTypeFieldSeparator; }
- (BOOL) isRangeSeparator		{ return self.type == APCScheduleExpressionTokenTypeRangeSeparator; }
- (BOOL) isPositionSeparator	{ return self.type == APCScheduleExpressionTokenTypePositionSeparator; }

// Stuff that failed.
- (BOOL) isNotYetParsed			{ return self.type == APCScheduleExpressionTokenTypeNotYetParsed; }
- (BOOL) isUnrecognized			{ return self.type == APCScheduleExpressionTokenTypeUnrecognized; }
- (BOOL) isScanningError		{ return self.type == APCScheduleExpressionTokenTypeScanningError; }

- (NSString *) description
{
	return [NSString stringWithFormat: @"Token { string: %@, integer: %d, isError: %@ }",
			self.stringValue,
			(int) self.integerValue,
			self.didEncounterError ? @"YES" : @"NO"
			];
}

@end
