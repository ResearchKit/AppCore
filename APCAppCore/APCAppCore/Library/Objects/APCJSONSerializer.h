// 
//  APCJSONSerializer.h 
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


/**
 These constants are used by a couple of different classes
 which prepare stuff for me to serialize.

 Imported (stolen, duplicated) from APCDataArchiver.
 Working on normalizing that.
 */
FOUNDATION_EXPORT NSString * const kAPCSerializedDataKey_QuestionType;
FOUNDATION_EXPORT NSString * const kAPCSerializedDataKey_QuestionTypeName;
FOUNDATION_EXPORT NSString * const kAPCSerializedDataKey_UserInfo;
FOUNDATION_EXPORT NSString * const kAPCSerializedDataKey_Identifier;
FOUNDATION_EXPORT NSString * const kAPCSerializedDataKey_Item;
FOUNDATION_EXPORT NSString * const kAPCSerializedDataKey_TaskRun;
FOUNDATION_EXPORT NSString * const kAPCSerializedDataKey_Files;
FOUNDATION_EXPORT NSString * const kAPCSerializedDataKey_AppName;
FOUNDATION_EXPORT NSString * const kAPCSerializedDataKey_AppVersion;
FOUNDATION_EXPORT NSString * const kAPCSerializedDataKey_FileInfoName;
FOUNDATION_EXPORT NSString * const kAPCSerializedDataKey_FileInfoTimeStamp;
FOUNDATION_EXPORT NSString * const kAPCSerializedDataKey_FileInfoContentType;


/**
 Contains a single public method that converts a dictionary,
 and all its contents, into data we can serialize into JSON
 using NSJSONSerializer.  That single public method
 does its work using verrrrrry specific rules, according to
 the needs of our application suite.
 
 Internally, it contains a bunch of similarly-named methods
 for other types of objects; we can expose those if needed.

 These methods all class methods.  I'm not sure this
 is necessary, but it's sufficient and helpful for now.

 All methods are thread-safe -- they operate only on the
 data you pass in.
 
 NOTE.  This class is used internally by the various
 .zip-and-send classes around the application suite;
 as of this writing, that's APCDataArchiverAndUploader,
 APCDataArchiver, and the APHAirQualityDataModel in Asthma.
 You probably don't need to call this yourself.  Instead,
 you can just zip-and-send your NSDictionary of stuff
 to one of those other tools, and they'll call this.
 This class was broken off into its own class -- its own
 file, really -- simply because it represents a nice,
 encapsulated piece of problem-solving, and it felt
 weird to have it shoved into another class whose job was,
 say, to .zip stuff or send stuff.
 */
@interface APCJSONSerializer : NSObject

/**
 Converts a dictionary, and all its contents, into data we
 can serialize into JSON using NSJSONSerializer.  Does its
 work using verrrrry specific rules, according to the needs
 of our application suite.
 
 Some examples of those rules:
 -  we convert the key "identifier" in a top-level
    dictionary to the word "item"
 -  we attempt to convert strings into integers and Booleans
 -  we stringify dates to ISO-8601 format
 -  we return nil for NSCalendars, intended to mean "please
    don't serialize this object," because we include the
    time zone in the NSDate conversions (above)
 -  Arrays and dictionaries will always be converted to
    arrays and dictionaries, even if they end up having
    no contents (evolving)

 This method is recursive, kind of.  If it encounters an array
 or dictionary, it'll call the same conversion routines on that
 object and its contents as it uses when serializing the top-
 level objects.
 */
+ (NSDictionary *) serializableDictionaryFromSourceDictionary: (NSDictionary *) sourceDictionary;

@end
