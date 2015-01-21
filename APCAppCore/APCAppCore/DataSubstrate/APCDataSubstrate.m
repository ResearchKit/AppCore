// 
//  APCDataSubstrate.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
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
        [self setUpHealthKit];
        [self setupParameters];
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

- (void) setupParameters {
    self.parameters = [[APCParameters alloc] initWithFileName:@"APCParameters.json"];
    [self.parameters setDelegate:self];
}

/*********************************************************************************/
#pragma mark - Properties & Methods meant only for Categories
/*************************************************s********************************/
- (void)parameters:(APCParameters *)parameters didFailWithError:(NSError *)error {
    NSAssert(error, @"parameters are not loaded");
}
@end
