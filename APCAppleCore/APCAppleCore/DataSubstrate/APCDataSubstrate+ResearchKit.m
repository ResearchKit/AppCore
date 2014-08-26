//
//  APCDataSubstrate+ResearchKit.m
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 8/26/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCDataSubstrate+ResearchKit.h"
#import "APCAppleCore.h"
#import <ResearchKit/ResearchKit.h>

extern NSString * const RKStudyStoreRestoredCollectorsKey;

@implementation APCDataSubstrate (ResearchKit)

/*********************************************************************************/
#pragma mark - ResearchKit Subsystem
/*********************************************************************************/
- (void) setUpResearchStudy: (NSString*) studyIdentifier
{
    self.studyStore = [RKStudyStore sharedStudyStore];
    NSError * error;
    self.study = [self.studyStore addStudyWithIdentifier:studyIdentifier delegate:self error:&error];
    [error handle];
    [self setUpCollectors];
}

//Abstract Methods with blank implementations
- (void) setUpCollectors { /* Blank implementation. Should be overridden by subclasses */}


/*********************************************************************************/
#pragma mark - Research Kit RKStudyDelegate
/*********************************************************************************/
- (void)studyStore:(RKStudyStore *)studyStore willRestoreState:(NSDictionary *)dict
{
    //TODO: Figure out what needs to be done here
    NSLog(@"Restoring store with dict: %@", dict);
}

@end
