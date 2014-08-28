//
//  APCTask+AddOn.m
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 8/28/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCTask+AddOn.h"
#import "APCModel.h"

@implementation APCTask (AddOn)



/*********************************************************************************/
#pragma mark - Life Cycle Methods
/*********************************************************************************/
- (void)awakeFromInsert
{
    [super awakeFromInsert];
    if (self.managedObjectContext.persistentStoreCoordinator) {
        [self setPrimitiveValue:[NSDate date] forKey:@"CreatedAt"];
    }
}

- (void)willSave
{
    if (self.managedObjectContext.persistentStoreCoordinator) {
        [self setPrimitiveValue:[NSDate date] forKey:@"UpdatedAt"];
    }
}

@end
