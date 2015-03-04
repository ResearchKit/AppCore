//
//  APCDataArchiver.h
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ResearchKit/ResearchKit.h>

@class ORKTaskResult;

@interface APCDataArchiver : NSObject

- (instancetype) initWithTaskResult: (ORKTaskResult*) taskResult;
- (instancetype)initWithResults: (NSArray*) results itemIdentifier: (NSString*) itemIdentifier runUUID: (NSUUID*) runUUID;
- (NSString*) writeToOutputDirectory: (NSString*) outputDirectory;

+ (BOOL) encryptZipFile: (NSString*) unencryptedPath encryptedPath:(NSString*) encryptedPath;


/**
 Converts the specified object to data we can serialize into
 JSON.  Sometimes, uses verrrrry specific rules to do this
 conversion.  Some examples of this oddness:
 -  we convert the key "identifier" in a top-level dictionary
    to the word "item"
 -  we attempt to convert strings into integers and Booleans
 -  we stringify dates to ISO-8601 format
 -  we return nil for NSCalendars, intended to mean "please
    don't serialize this object," because we include the
    time zone in the NSDate conversions (above)
 -  Arrays and dictionaries will always be converted to
    arrays and dictionaries, even if they end up having
    no contents (evolving)
 
 This method is recursive.  If it encounters an array or
 dictionary, it'll call the same conversion routines on that
 object and its contents.
 */
- (NSDictionary *) generateSerializableDataFromSourceDictionary: (NSDictionary *) sourceDictionary;


/*
 Make sure crackers (Bad Guys) don't know these features
 exist, and (also) cannot use them, even by accident.
 */
#ifdef USE_DATA_VERIFICATION_CLIENT

	/**
	 Should we save the unencrypted .zip file?  Specifically
	 so we can retrieve it with -unencryptedFilePath?
	 */
	@property (nonatomic) BOOL preserveUnencryptedFile;

	/**
	 The path where the unencrypted .zip file was generated.
	 If you set -preserveUnencryptedFile to YES, the file will
	 exist at this path after the -init process has finished
	 creating the .zip file.
	 */
	@property (nonatomic, strong) NSString *unencryptedFilePath;

#endif


@end
