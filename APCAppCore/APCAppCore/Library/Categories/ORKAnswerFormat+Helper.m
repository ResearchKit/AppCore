//
//  ORKAnswerFormat+Helper.m
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "ORKAnswerFormat+Helper.h"


@implementation ORKAnswerFormat (Helper)

+ (NSString *) stringFromQuestionType: (ORKQuestionType) questionType
{
	NSString *result = nil;

	switch (questionType)
	{
		case ORKQuestionTypeNone:			result = @"None";				break;
		case ORKQuestionTypeScale:			result = @"Scale";				break;
		case ORKQuestionTypeSingleChoice:	result = @"SingleChoice";		break;
		case ORKQuestionTypeMultipleChoice:	result = @"MultipleChoice";		break;
		case ORKQuestionTypeDecimal:			result = @"Decimal";			break;
		case ORKQuestionTypeInteger:			result = @"Integer";			break;
		case ORKQuestionTypeBoolean:			result = @"Boolean";			break;
		case ORKQuestionTypeText:			result = @"Text";				break;
		case ORKQuestionTypeTimeOfDay:		result = @"TimeOfDay";			break;
		case ORKQuestionTypeDateAndTime:		result = @"DateAndTime";		break;
		case ORKQuestionTypeDate:			result = @"Date";				break;
		case ORKQuestionTypeTimeInterval:	result = @"TimeInterval";		break;

		default:
			result = RKQuestionTypeUnknownAsString;
			break;
	}

	return result;
}

NSString * NSStringFromRKQuestionType (ORKQuestionType questionType)
{
	NSString *result = [ORKAnswerFormat stringFromQuestionType: questionType];

	return result;
}

@end
