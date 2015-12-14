//
//  APCTaskResultArchiver.h
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

#import <Foundation/Foundation.h>
#import <ResearchKit/ResearchKit.h>

NS_ASSUME_NONNULL_BEGIN

@class APCDataArchive;
@class APCTask;

extern NSString * const APCDefaultTranslationFilename;

@interface APCTaskResultArchiver : NSObject

/**
 Method for appending a task result to a given archive. Exposed for testing and to allow use of this archive with
 a data archive that is a subclass of APCDataArchive.
 
 @param     archive        APCDataArchive into which result is archived
 @param     result         ORKTaskResult to process
 */
- (void)appendArchive:(APCDataArchive*)archive withTaskResult:(ORKTaskResult *)result;

/**
 Factory method for appending various results into the given archive. Subclasses must overrride to implement archiving
 that is not of a class type that is known by this archiver.
 
 @param     archive        APCDataArchive into which result is archived
 @param     result         ORKResult to process
 @param     stepResult     ORKStepResult of which this result is a subcomponent
 @return    success        @YES if successfully archived, @NO if failed to archive.
 */
- (BOOL)appendArchive:(APCDataArchive*)archive withResult:(ORKResult *)result forStepResult:(ORKStepResult*)stepResult;

/**
 Dictionary used for the translation of a step result identifier into
 the filename to use when archiving. By default, this dictionary is populated by
 a file FilenameTranslation.json embedded as a resource in the main bundle.
  If the file does not exist then an empty one is created.
 */
@property (nonatomic, strong) NSDictionary *filenameTranslationDictionary;

/**
 Translates the fileResult identifier and stepIdentifier via concatenation in the following scheme:
 fileResultIdentifier_stepIdentifer.
 Looks up the concatenated identifiers in filenameTranslationDictionary
 If the string exists, returns the value for the key in the json file.
 
 @param     fileResultIdentifier        ORKResult identifier
 @param     stepIdentifier              ORKStep identifier
 @return    filename                    translated filename if exists in FilenameTranslation.json, else the concatenated string <fileResultIdentifier>_<stepIdentifer>.<extension>
 */
- (NSString *)filenameForFileResultIdentifier: (NSString * _Nullable )fileResultIdentifier stepIdentifier: (NSString * _Nullable)stepIdentifier extension:(NSString * _Nullable)extension;

/**
 Factory method for getting the filename to use for a given subresult of a given step result.

 @param         result                  ORKResult
 @param         stepResult              parent ORKStepResult
 @return        filename                translated filename for this type of result
 */
- (NSString *)filenameForResult:(ORKResult*)result stepResult:(ORKStepResult *)stepResult;

@end

NS_ASSUME_NONNULL_END
