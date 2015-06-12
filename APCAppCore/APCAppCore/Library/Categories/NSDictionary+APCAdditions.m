// 
//  NSDictionary+APCAdditions.m 
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
 
#import "NSDictionary+APCAdditions.h"
#import "APCAppCore.h"

static  NSString  *daysOfWeekNames[]     = { @"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday", @"Sunday" };
static  NSUInteger  numberOfDaysOfWeek   = (sizeof(daysOfWeekNames) / sizeof(NSString *));
static  NSString  *oneThroughFiveNames[] = { @"Once", @"Two times", @"Three times", @"Four times", @"Five times" };

static NSString * const APCErrorDomainLoadingDictionary             = @"APCErrorDomainLoadingDictionary";
static NSInteger  const APCErrorLoadingJsonNoFileCode               = 1;
static NSString * const APCErrorLoadingJsonNoFileReason             = @"Can't Find JSON File";
static NSString * const APCErrorLoadingJsonNoFileSuggestion         = @"We were unable to find a file with the specified filename.";
static NSInteger  const APCErrorLoadingJsonNoDictionaryCode         = 2;
static NSString * const APCErrorLoadingJsonNoDictionaryReason       = @"Can't Understand JSON File";
static NSString * const APCErrorLoadingJsonNoDictionarySuggestion   = @"We were unable to find a dictionary at the top level of the JSON file at the specified path.";

@implementation NSDictionary (APCAdditions)

- (NSString *)JSONString
{
    NSError * error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:&error];
    APCLogError2 (error);
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

+ (instancetype)dictionaryWithJSONString:(NSString *)string
{
    NSData *resultData = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSDictionary * retValue = [NSJSONSerialization JSONObjectWithData:resultData
                                             options:NSJSONReadingAllowFragments
                                               error:&error];
    APCLogError2 (error);
    return retValue;
}

    //
    //    to support Medication Tracking Requirements
    //
- (NSString *)formatNumbersAndDays
{
    NSDictionary  *mapper = @{ @"Monday" : @"Mon", @"Tuesday" : @"Tue", @"Wednesday" : @"Wed", @"Thursday" : @"Thu", @"Friday" : @"Fri", @"Saturday" : @"Sat", @"Sunday" : @"Sun" };
    
    BOOL  everyday = YES;
    NSNumber  *saved = nil;
    NSArray  *all = [self allValues];
    for (NSNumber  *number  in  all) {
        if ([number integerValue] > 0) {
            saved = number;
        } else {
            everyday = NO;
            break;
        }
    }
    
    NSString  *result = @"";
    if (everyday) {
        if ([saved unsignedIntegerValue] > 5) {
            result = [NSString stringWithFormat:@"%lu times Every Day", (unsigned long)[saved unsignedIntegerValue]];
        } else {
            result = [NSString stringWithFormat:@"%@ Every Day", oneThroughFiveNames[[saved unsignedIntegerValue] - 1]];
        }
    } else {
        NSMutableString  *daysAndNumbers = [NSMutableString string];
        for (NSUInteger  day = 0;  day < numberOfDaysOfWeek;  day++) {
            NSString  *key = daysOfWeekNames[day];
            NSNumber  *number = [self objectForKey:key];
            if ([number integerValue] > 0) {
                if ([saved unsignedIntegerValue] > 5) {
                    if (daysAndNumbers.length == 0) {
                        [daysAndNumbers appendFormat:@"%lu times on %@", (unsigned long)[number unsignedIntegerValue], mapper[key]];
                    } else {
                        [daysAndNumbers appendFormat:@", %@", mapper[key]];
                    }
                } else {
                    if (daysAndNumbers.length == 0) {
                        [daysAndNumbers appendFormat:@"%@ on %@", oneThroughFiveNames[[number unsignedIntegerValue] - 1], mapper[key]];
                    } else {
                        [daysAndNumbers appendFormat:@", %@", mapper[key]];
                    }
                }
            }
        }
        result = daysAndNumbers;
    }
    return  result;
}

+ (NSDictionary *) dictionaryWithContentsOfJSONFileWithName: (NSString *) filename
                                                   inBundle: (NSBundle *) bundle
                                             returningError: (NSError * __autoreleasing *) errorToReturn
{
    if (bundle == nil)
    {
        bundle = [NSBundle mainBundle];
    }

    NSError *localError = nil;
    NSDictionary *jsonDictionary = nil;
    NSString *extension = filename.pathExtension;
    NSString *basename = [filename substringToIndex: filename.length - extension.length - 1];

    NSString *pathToJSONFile = [bundle pathForResource: basename
                                                ofType: extension];

    if (! pathToJSONFile)
    {
        localError = [NSError errorWithCode: APCErrorLoadingJsonNoFileCode
                                     domain: APCErrorDomainLoadingDictionary
                              failureReason: APCErrorLoadingJsonNoFileReason
                         recoverySuggestion: APCErrorLoadingJsonNoFileSuggestion
                            relatedFilePath: filename];
    }
    else
    {
        NSError *errorReadingFile = nil;
        NSData *maybeJsonData = [NSData dataWithContentsOfFile: pathToJSONFile
                                                       options: 0
                                                         error: & errorReadingFile];

        if (! maybeJsonData)
        {
            localError = errorReadingFile;
        }
        else
        {
            NSError *errorConvertingToJSON = nil;
            id maybeJsonDictionary = [NSJSONSerialization JSONObjectWithData: maybeJsonData
                                                                     options: NSJSONReadingMutableContainers
                                                                       error: & errorConvertingToJSON];

            if (! maybeJsonDictionary)
            {
                localError = errorConvertingToJSON;
            }

            else if (! [maybeJsonDictionary isKindOfClass: [NSDictionary class]])
            {
                localError = [NSError errorWithCode: APCErrorLoadingJsonNoDictionaryCode
                                             domain: APCErrorDomainLoadingDictionary
                                      failureReason: APCErrorLoadingJsonNoDictionaryReason
                                 recoverySuggestion: APCErrorLoadingJsonNoDictionarySuggestion
                                    relatedFilePath: pathToJSONFile];
            }
            
            else
            {
                // Done!
                jsonDictionary = maybeJsonDictionary;
            }
        }
    }

    if (errorToReturn != nil)
    {
        * errorToReturn = localError;
    }
    
    return jsonDictionary;
}

@end
