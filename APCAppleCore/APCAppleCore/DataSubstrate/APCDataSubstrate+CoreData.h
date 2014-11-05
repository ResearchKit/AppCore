//
//  APCDataSubstrate+CoreData.h
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 8/26/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCDataSubstrate.h"

@interface APCDataSubstrate (CoreData)

/*********************************************************************************/
#pragma mark - Core Data Public Methods
/*********************************************************************************/
- (void)loadStaticTasksAndSchedules: (NSDictionary*) jsonDictionary;
- (void) resetCoreData; //EXERCISE CAUTION IN CALLING THIS METHOD

/*********************************************************************************/
#pragma mark - Helpers - ONLY RETURNS IN NSManagedObjects in mainContext
/*********************************************************************************/
- (NSFetchRequest*) requestForScheduledTasksDueFrom:(NSDate *)fromDate toDate:(NSDate *)toDate sortDescriptors: (NSArray*) sortDescriptors;
- (NSArray *)scheduledTasksDueFrom:(NSDate *)fromDate toDate:(NSDate *)toDate sortDescriptors: (NSArray*) sortDescriptors; //NOTE: Excludes toDate
- (NSFetchRequest*) requestForScheduledTasksForPredicate:(NSPredicate *)predicate sortDescriptors: (NSArray*) sortDescriptors;
- (NSArray *)scheduledTasksForPredicate:(NSPredicate *)predicate sortDescriptors: (NSArray*) sortDescriptors;
- (NSUInteger) allScheduledTasksForToday;
- (NSUInteger) completedScheduledTasksForToday;


/*********************************************************************************/
#pragma mark - Methods meant only for Categories
/*********************************************************************************/
- (void) setUpCoreDataStackWithPersistentStorePath:(NSString*) storePath additionalModels: (NSManagedObjectModel*) mergedModels;

@end
