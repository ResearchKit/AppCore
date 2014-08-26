//
//  APCDataSubstrate.h
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 8/25/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ResearchKit/ResearchKit.h>

@class  NSManagedObjectContext, NSManagedObjectModel;

@interface APCDataSubstrate : NSObject <RKStudyDelegate>

/*********************************************************************************/
#pragma mark - Initializer
/*********************************************************************************/
- (instancetype)initWithPersistentStorePath: (NSString*) storePath additionalModels:(NSManagedObjectModel *)mergedModels studyIdentifier: (NSString*) studyIdentifier;

/*********************************************************************************/
#pragma mark - ResearchKit Subsystem
/*********************************************************************************/
@property (nonatomic, strong) RKStudyStore * studyStore;


/*********************************************************************************/
#pragma mark - Core Data Subsystem
/*********************************************************************************/
@property (nonatomic, strong) NSManagedObjectContext * mainContext;
@property (nonatomic, strong) NSManagedObjectContext * persistentContext;


@end
