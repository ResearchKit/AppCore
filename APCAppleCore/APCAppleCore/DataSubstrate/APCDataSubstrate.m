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
        [self setUpResearchStudy:studyIdentifier];
        [self setUpCoreDataStackWithPersistentStorePath:storePath additionalModels:mergedModels];
        [self setUpHealthKit];
        [self setUpCurrentUser];
    }
    return self;
}

- (void) setUpCurrentUser
{
    static APCUser * sharedUser = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedUser = [[APCUser alloc] init];
    });
}

@end
