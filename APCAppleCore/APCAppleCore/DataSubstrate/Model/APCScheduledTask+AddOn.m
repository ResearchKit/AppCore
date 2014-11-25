//
//  APCScheduledTask+AddOn.m
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 8/29/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCScheduledTask+AddOn.h"
#import "APCAppleCore.h"

@implementation APCScheduledTask (AddOn)

- (void)completeScheduledTask
{
    self.completed = @(YES);
    
    //Turn off one time schedule
    if ([self.generatedSchedule isOneTimeSchedule])
    {
        self.generatedSchedule.inActive = @(YES);
    }
    NSError * saveError;
    [self saveToPersistentStore:&saveError];
    [saveError handle];
}

- (void) createLocalNotification
{
    //TODO: to be done
}

- (void) deleteLocalNotification
{
    //TODO: to be done
}

- (void) deleteScheduledTask
{
    [self deleteLocalNotification];
    [self.managedObjectContext deleteObject:self];
    NSError * saveError;
    [self saveToPersistentStore:&saveError];
    [saveError handle];
}

+ (NSArray *)allScheduledTasksForTodayInContext: (NSManagedObjectContext*) context
{
    NSFetchRequest * request = [APCScheduledTask request];
    //Support multiday
    request.predicate = [NSPredicate predicateWithFormat:@"startOn >= %@ && endOn < %@", [NSDate todayAtMidnight], [NSDate tomorrowAtMidnight]];
    NSSortDescriptor *dateSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"startOn" ascending:YES];
    request.sortDescriptors = @[dateSortDescriptor];
    NSError * error;
    NSArray * array = [context executeFetchRequest:request error:&error];
    [error handle];
    return array.count ? array : nil;
}

+ (instancetype) scheduledTaskForStartOnDate: (NSDate *) startOn schedule: (APCSchedule*) schedule inContext: (NSManagedObjectContext*) context
{
    NSFetchRequest * request = [APCScheduledTask request];
    request.predicate = [NSPredicate predicateWithFormat:@"startOn == %@ && generatedSchedule == %@", startOn, schedule];
    NSError * error;
    NSArray * array = [context executeFetchRequest:request error:&error];
    [error handle];
    return array.count ? [array firstObject] : nil;
}


/*********************************************************************************/
#pragma mark - Life Cycle Methods
/*********************************************************************************/
- (void)awakeFromInsert
{
    [super awakeFromInsert];
    [self setPrimitiveValue:[NSDate date] forKey:@"createdAt"];
}

- (void)willSave
{
    [self setPrimitiveValue:[NSDate date] forKey:@"updatedAt"];
}

@end
