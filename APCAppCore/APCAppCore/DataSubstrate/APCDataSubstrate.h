//
//  APCDataSubstrate.h
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 8/25/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ResearchKit/ResearchKit.h>
#import <ResearchKit/ResearchKit_Private.h>
#import <CoreData/CoreData.h>
#import "APCPassiveLocationTracking.h"
#import <HealthKit/HealthKit.h>
#import "APCParameters.h"

@class APCUser;

@protocol APCDataSubstrateProtocol <NSObject>

- (void) setUpCollectors;

@end

@interface APCDataSubstrate : NSObject <RKSTStudyDelegate, APCParametersDelegate>

/*********************************************************************************/
#pragma mark - Initializer
/*********************************************************************************/
- (instancetype)initWithPersistentStorePath: (NSString*) storePath additionalModels:(NSManagedObjectModel *)mergedModels studyIdentifier: (NSString*) studyIdentifier;

@property (nonatomic, weak) id<APCDataSubstrateProtocol> delegate;

/*********************************************************************************/
#pragma mark - ResearchKit Subsystem Public Properties & Passive Location Tracking
/*********************************************************************************/
@property (assign) BOOL justJoined;
@property (strong, nonatomic) NSString *logDirectory;
@property (strong, nonatomic) RKSTDataLoggerManager *logManager;
@property (nonatomic, strong) APCUser * currentUser;

@property (strong, nonatomic) APCPassiveLocationTracking *passiveLocationTracking;

/*********************************************************************************/
#pragma mark - Core Data Subsystem Public Properties
/*********************************************************************************/
//Main context for use in View Controllers, Fetch Results Controllers etc.
@property (nonatomic, strong) NSManagedObjectContext * mainContext;

//Persistent context: Parent of main context.
//Please create a child context of persistentContext for any background processing tasks
@property (nonatomic, strong) NSManagedObjectContext * persistentContext;

/*********************************************************************************/
#pragma mark - Healthkit Public Properties
/*********************************************************************************/
@property (nonatomic, strong) HKHealthStore * healthStore;

/*********************************************************************************/
#pragma mark - Properties & Methods meant only for Categories
/*********************************************************************************/
//ResearchKit Subsystem
@property (nonatomic, strong) RKSTStudyStore * studyStore;
@property (nonatomic, strong) RKSTStudy * study; //Assumes only one study per app

//Core Data Subsystem
@property (nonatomic, strong) NSString * storePath;
@property (nonatomic, strong) NSPersistentStoreCoordinator * persistentStoreCoordinator;
@property (nonatomic, strong) NSManagedObjectModel * managedObjectModel;

//HealthKit Subsystem
/*********************************************************************************/
#pragma mark - Parameters
/*********************************************************************************/
@property (strong, nonatomic) APCParameters *parameters;


@end
