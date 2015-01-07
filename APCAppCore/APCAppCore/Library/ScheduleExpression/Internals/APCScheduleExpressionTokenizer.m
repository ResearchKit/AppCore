//
//  APCScheduleExpressionTokenizer.m
//  AppCore
//
//  Copyright (c) 2015 Apple Inc. All rights reserved.
//

#import "APCScheduleExpressionTokenizer.h"
#import "APCScheduleExpressionToken.h"


static NSCharacterSet* kAlphaCharacterSet = nil;
static NSCharacterSet* kDigitsCharacterSet = nil;
static NSCharacterSet* kWildcardCharacterSet = nil;
static NSCharacterSet* kListSeparatorCharacterSet = nil;
static NSCharacterSet* kStepSeparatorCharacterSet = nil;
static NSCharacterSet* kFieldSeparatorCharacterSet = nil;
static NSCharacterSet* kRangeSeparatorCharacterSet = nil;
static NSCharacterSet* kPositionSeparatorCharacterSet = nil;
static NSCharacterSet* kAllCharsWeRecognizeCharacterSet = nil;


@implementation APCScheduleExpressionTokenizer

/**
 This method runs exactly once, in a thread-safe way,
 the first time the class is referenced in the code.
 */
+ (void) initialize
{
	if (kDigitsCharacterSet == nil)
	{
		kAlphaCharacterSet				= [NSCharacterSet letterCharacterSet];
		kDigitsCharacterSet				= [NSCharacterSet decimalDigitCharacterSet];
		kWildcardCharacterSet			= [NSCharacterSet characterSetWithCharactersInString: @"*?"];
		kListSeparatorCharacterSet		= [NSCharacterSet characterSetWithCharactersInString: @","];
		kStepSeparatorCharacterSet		= [NSCharacterSet characterSetWithCharactersInString: @"/"];
		kFieldSeparatorCharacterSet		= [NSCharacterSet whitespaceAndNewlineCharacterSet];
		kRangeSeparatorCharacterSet		= [NSCharacterSet characterSetWithCharactersInString: @"-"];
		kPositionSeparatorCharacterSet	= [NSCharacterSet characterSetWithCharactersInString: @"#"];

		NSMutableCharacterSet *allCharsWeRecognize = [NSMutableCharacterSet new];
		[allCharsWeRecognize formUnionWithCharacterSet: kAlphaCharacterSet];
		[allCharsWeRecognize formUnionWithCharacterSet: kDigitsCharacterSet];
		[allCharsWeRecognize formUnionWithCharacterSet: kWildcardCharacterSet];
		[allCharsWeRecognize formUnionWithCharacterSet: kListSeparatorCharacterSet];
		[allCharsWeRecognize formUnionWithCharacterSet: kStepSeparatorCharacterSet];
		[allCharsWeRecognize formUnionWithCharacterSet: kFieldSeparatorCharacterSet];
		[allCharsWeRecognize formUnionWithCharacterSet: kRangeSeparatorCharacterSet];
		[allCharsWeRecognize formUnionWithCharacterSet: kPositionSeparatorCharacterSet];
		kAllCharsWeRecognizeCharacterSet = allCharsWeRecognize;
	}
}

- (APCScheduleExpressionToken *) nextTokenFromString: (NSString *) string
{
	APCScheduleExpressionToken *token = [APCScheduleExpressionToken new];
	NSString *scannedText = nil;
	NSScanner* scanner = [NSScanner scannerWithString: string];

	/*
	 It seems standard to put "whitespace and newlines" here.
	 However, for us, whitespace and newlines matter:  they're
	 the "field delimiter".
	 */
	scanner.charactersToBeSkipped = nil;

	/*
	 All the text we care about is case-insensitive.
	 */
	scanner.caseSensitive = NO;


	/*
	 Find the first token in the string.
	 
	 Since the parser will eventually "consume" these
	 characters from the front of the string, this
	 also means:  "find the next token," conceptually.

	 For readability, I'm going to do the scanning, and
	 set the types, right here.  Then I'll set the other
	 fields, as needed.
	 */
	token.type =
	(
	 // Character types we recognize.
	 [scanner scanCharactersFromSet: kAlphaCharacterSet				intoString: &scannedText] ? APCScheduleExpressionTokenTypeWord :
	 [scanner scanCharactersFromSet: kDigitsCharacterSet			intoString: &scannedText] ? APCScheduleExpressionTokenTypeNumber :
	 [scanner scanCharactersFromSet: kWildcardCharacterSet			intoString: &scannedText] ? APCScheduleExpressionTokenTypeWildcard :
	 [scanner scanCharactersFromSet: kListSeparatorCharacterSet		intoString: &scannedText] ? APCScheduleExpressionTokenTypeListSeparator :
	 [scanner scanCharactersFromSet: kStepSeparatorCharacterSet		intoString: &scannedText] ? APCScheduleExpressionTokenTypeStepSeparator :
	 [scanner scanCharactersFromSet: kFieldSeparatorCharacterSet	intoString: &scannedText] ? APCScheduleExpressionTokenTypeFieldSeparator :
	 [scanner scanCharactersFromSet: kRangeSeparatorCharacterSet	intoString: &scannedText] ? APCScheduleExpressionTokenTypeRangeSeparator :
	 [scanner scanCharactersFromSet: kPositionSeparatorCharacterSet	intoString: &scannedText] ? APCScheduleExpressionTokenTypePositionSeparator :

	 // We didn't recognize it.  Try to find where
	 // the next thing-we-recognize begins.
	 [scanner scanUpToCharactersFromSet: kAllCharsWeRecognizeCharacterSet intoString: &scannedText] ? APCScheduleExpressionTokenTypeUnrecognized :

	 // Well, that's odd.  We couldn't even do that.
	 // (This should literally never happen.)
	 APCScheduleExpressionTokenTypeScanningError
	 );


	/*
	 Set other fields based on what just happened.
	 */
	token.countOfScannedCharacters = scanner.scanLocation;
	token.stringValue = scannedText;

	switch (token.type)
	{
		case APCScheduleExpressionTokenTypeNumber:
			token.integerValue = scannedText.integerValue;
			break;

		case APCScheduleExpressionTokenTypeNotYetParsed:
			token.didEncounterError = YES;
			token.errorMessage = @"Somehow, the tokenizer never finished.  You should literally never see this message.";
			break;

		case APCScheduleExpressionTokenTypeUnrecognized:
			token.didEncounterError = YES;
			token.errorMessage = [NSString stringWithFormat: @"Couldn't understand token [%@] in the expression [%@].", scannedText, string];
			break;

		case APCScheduleExpressionTokenTypeScanningError:
			token.didEncounterError = YES;
			token.errorMessage = [NSString stringWithFormat: @"Something very odd happened when trying to scan the cron expression:  we didn't find any recognized OR UNRECOGNIZED characters at the beginning of this string: [%@].", string];
			break;

		default:
			// Everything else has already been handled.
			break;
	}

	return token;
}

@end













