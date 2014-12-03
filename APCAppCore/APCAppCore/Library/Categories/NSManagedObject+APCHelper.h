//
//  NSManagedObject+APCHelper.h
//  APCAppCore
//
//  Created by Dhanush Balachandran on 8/28/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
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
