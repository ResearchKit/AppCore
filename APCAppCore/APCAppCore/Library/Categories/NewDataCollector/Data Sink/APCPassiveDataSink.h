//
//  APCPassiveDataSink.h
//  APCAppCore
//
//  Created by Justin Warmkessel on 4/7/15.
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface APCPassiveDataSink : NSObject 

@property (nonatomic, strong) NSMutableDictionary * registeredTrackers;
@property (nonatomic, strong) NSString * collectorsPath;
@property (nonatomic, readonly) NSString *collectorsUploadPath;

//Unique configuration for collector
@property (nonatomic, readonly) NSString*       identifier;
@property (nonatomic, strong)   NSDictionary*   infoDictionary;
@property (nonatomic, strong)   NSString*       folder;
@property (nonatomic)           NSTimeInterval  stalenessInterval;
@property (nonatomic) unsigned long long        sizeThreshold;
@property (nonatomic)           NSArray*        columnNames;

@property (nonatomic, strong) NSString*         csvFilename;
@property (nonatomic, strong) NSOperationQueue* healthKitCollectorQueue;


- (instancetype)initWithIdentifier:(NSString *)identifier andColumnNames:(NSArray *)columnNames;

- (void) checkIfDataNeedsToBeFlushed;

+ (void) createOrAppendString: (NSString*) string toFile: (NSString*) path;
+ (void) createOrReplaceString: (NSString*) string toFile: (NSString*) path;
+ (void) createFolderIfDoesntExist: (NSString*) path;
+ (void) deleteFileIfExists: (NSString*) path;

@end
