//
//  APCDataSubstrate+ResearchKit.h
//  APCAppCore
//
//  Created by Dhanush Balachandran on 8/26/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
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
