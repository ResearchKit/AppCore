//
//  APCDataSubstrate+ResearchKit.h
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 8/26/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCDataSubstrate.h"

@interface APCDataSubstrate (ResearchKit) <RKDataLoggerManagerDelegate>

/*********************************************************************************/
#pragma mark - Public Methods
/*********************************************************************************/
//Abstract Methods with blank implementations
- (void) setUpCollectors;

/*********************************************************************************/
#pragma mark - Methods meant only for Categories
/*********************************************************************************/
- (void) setUpResearchStudy: (NSString*) studyIdentifier;

@end
