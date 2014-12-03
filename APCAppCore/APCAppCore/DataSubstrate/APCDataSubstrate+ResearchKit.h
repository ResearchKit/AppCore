// 
//  APCDataSubstrate+ResearchKit.h 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "APCDataSubstrate.h"

@interface APCDataSubstrate (ResearchKit) <RKSTDataLoggerManagerDelegate>

/*********************************************************************************/
#pragma mark - Methods meant only for Categories
/*********************************************************************************/
- (void) setUpResearchStudy: (NSString*) studyIdentifier;
- (void) joinStudy;
- (void) leaveStudy;

@end
