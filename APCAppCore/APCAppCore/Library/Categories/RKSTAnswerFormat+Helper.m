//
//  RKSTAnswerFormat+Helper.m
//  AppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "RKSTAnswerFormat+Helper.h"


@implementation RKSTAnswerFormat (Helper)

+ (NSString *) stringFromQuestionType: (RKQuestionType) questionType
{
	NSString *result = nil;

	switch (questionType)
	{
		case RKQuestionTypeNone:			result = @"None";				break;
		case RKQuestionTypeScale:			result = @"Scale";				break;
		case RKQuestionTypeSingleChoice:	result = @"SingleChoice";		break;
		case RKQuestionTypeMultipleChoice:	result = @"MultipleChoice";		break;
		case RKQuestionTypeDecimal:			result = @"Decimal";			break;
		case RKQuestionTypeInteger:			result = @"Integer";			break;
		case RKQuestionTypeBoolean:			result = @"Boolean";			break;
		case RKQuestionTypeText:			result = @"Text";				break;
		case RKQuestionTypeTimeOfDay:		result = @"TimeOfDay";			break;
		case RKQuestionTypeDateAndTime:		result = @"DateAndTime";		break;
		case RKQuestionTypeDate:			result = @"Date";				break;
		case RKQuestionTypeTimeInterval:	result = @"TimeInterval";		break;

		default:
			result = RKQuestionTypeUnknownAsString;
			break;
	}

	return result;
}

NSString * NSStringFromRKQuestionType (RKQuestionType questionType)
{
	NSString *result = [RKSTAnswerFormat stringFromQuestionType: questionType];

	return result;
}

@end
