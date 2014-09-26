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

@implementation APCDataSubstrate

- (instancetype)initWithPersistentStorePath: (NSString*) storePath additionalModels:(NSManagedObjectModel *)mergedModels studyIdentifier:(NSString *)studyIdentifier
{
    self = [super init];
    if (self) {
        
        //TODO check if current user has given consent and authorization
        //if (self.currentUser.givesConsent) {

        self.passiveLocationTracking = [[APCPassiveLocationTracking alloc] initWithTimeInterval:60];
        [self.passiveLocationTracking start];
        
        [self setUpResearchStudy:studyIdentifier];
        
        //}
        
        [self setUpCoreDataStackWithPersistentStorePath:storePath additionalModels:mergedModels];
    }
    return self;
}



@end
