//
//  APCDataSubstrate.h
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 8/25/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ResearchKit/ResearchKit.h>
#import <CoreData/CoreData.h>


@interface APCDataSubstrate : NSObject <RKStudyDelegate>

/*********************************************************************************/
#pragma mark - Initializer
/*********************************************************************************/
- (instancetype)initWithPersistentStorePath: (NSString*) storePath additionalModels:(NSManagedObjectModel *)mergedModels studyIdentifier: (NSString*) studyIdentifier;

/*********************************************************************************/
#pragma mark - ResearchKit Subsystem Public Properties
/*********************************************************************************/



/*********************************************************************************/
#pragma mark - Core Data Subsystem Public Properties
/*********************************************************************************/
//Main context for use in View Controllers, Fetch Results Controllers etc.
@property (nonatomic, strong) NSManagedObjectContext * mainContext;

//Persistent context: Parent of main context.
//Please create a child context of persistentContext for any background processing tasks
@property (nonatomic, strong) NSManagedObjectContext * persistentContext;


/*********************************************************************************/
#pragma mark - Properties & Methods meant only for Categories
/*********************************************************************************/
//ResearchKit Subsystem
@property (nonatomic, strong) RKStudyStore * studyStore;
@property (nonatomic, strong) RKStudy * study; //Assumes only one study per app

//Core Data Subsystem
@property (nonatomic, strong) NSPersistentStoreCoordinator * persistentStoreCoordinator;
@property (nonatomic, strong) NSManagedObjectModel * managedObjectModel;

@end
