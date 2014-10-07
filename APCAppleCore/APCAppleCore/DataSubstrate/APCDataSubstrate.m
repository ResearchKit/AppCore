//
//  APCDataSubstrate.m
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 8/25/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCDataSubstrate.h"
#import "APCDataSubstrate+ResearchKit.h"
#import "APCDataSubstrate+CoreData.h"
#import "APCDataSubstrate+HealthKit.h"
#import "APCModel.h"

@implementation APCDataSubstrate

- (instancetype)initWithPersistentStorePath: (NSString*) storePath additionalModels:(NSManagedObjectModel *)mergedModels studyIdentifier:(NSString *)studyIdentifier
{
    self = [super init];
    if (self) {
        [self setUpCoreDataStackWithPersistentStorePath:storePath additionalModels:mergedModels];
        [self setUpCurrentUser:self.persistentContext];
        [self setUpResearchStudy:studyIdentifier];
        [self setUpHealthKit];
    }
    return self;
}

- (void) setUpCurrentUser: (NSManagedObjectContext*) context
{
    if (!_currentUser) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _currentUser = [[APCUser alloc] initWithContext:context];
        });
    }
}


@end
