// 
//  APCDataSubstrate.h 
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
//
 
#import <Foundation/Foundation.h>
#import <ResearchKit/ResearchKit.h>
#import <CoreData/CoreData.h>
#import "APCCoreLocationTracker.h"
#import <HealthKit/HealthKit.h>
#import "APCParameters.h"

@class APCUser;

@interface APCDataSubstrate : NSObject <APCParametersDelegate>

/*********************************************************************************/
#pragma mark - Initializer
/*********************************************************************************/
- (instancetype)initWithPersistentStorePath: (NSString*) storePath additionalModels:(NSManagedObjectModel *)mergedModels studyIdentifier: (NSString*) studyIdentifier;

/*********************************************************************************/
#pragma mark - ResearchKit Subsystem Public Properties & Passive Location Tracking
/*********************************************************************************/
@property (assign) BOOL justJoined;
@property (strong, nonatomic) NSString *logDirectory;
@property (nonatomic, strong) APCUser * currentUser;

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
