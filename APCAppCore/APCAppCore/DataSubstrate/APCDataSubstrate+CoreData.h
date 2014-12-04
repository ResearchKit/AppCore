// 
//  APCDataSubstrate+CoreData.h 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "APCDataSubstrate.h"

@interface APCDataSubstrate (CoreData)

/*********************************************************************************/
#pragma mark - Core Data Public Methods
/*********************************************************************************/
- (void) loadStaticTasksAndSchedules: (NSDictionary*) jsonDictionary;
- (void) resetCoreData; //EXERCISE CAUTION IN CALLING THIS METHOD

/*********************************************************************************/
#pragma mark - Helpers - ONLY RETURNS IN NSManagedObjects in mainContext
/*********************************************************************************/
- (NSUInteger) countOfAllScheduledTasksForToday;
- (NSUInteger) countOfCompletedScheduledTasksForToday;


/*********************************************************************************/
#pragma mark - Methods meant only for Categories
/*********************************************************************************/
- (void) setUpCoreDataStackWithPersistentStorePath:(NSString*) storePath additionalModels: (NSManagedObjectModel*) mergedModels;

@end
