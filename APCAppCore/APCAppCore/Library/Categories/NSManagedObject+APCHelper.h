// 
//  NSManagedObject+APCHelper.h 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import <CoreData/CoreData.h>

@interface NSManagedObject (APCHelper)
/*********************************************************************************/
#pragma mark - Class Methods
/*********************************************************************************/
+ (instancetype) newObjectForContext: (NSManagedObjectContext*) context;
+ (NSFetchRequest*) request;

/*********************************************************************************/
#pragma mark - Instance Methods
/*********************************************************************************/
- (BOOL)saveToPersistentStore:(NSError *__autoreleasing *)error;

@end
