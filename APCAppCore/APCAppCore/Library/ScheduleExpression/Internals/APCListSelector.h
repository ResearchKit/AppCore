// 
//  APCListSelector.h 
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
//
 
#import "APCTimeSelector.h"
#import "APCPointSelector.h"

//  Private implementation.
//  Disjunction selector: if any of the sub-selectors matches then the selector matches

@interface APCListSelector : APCTimeSelector

@property (nonatomic, strong) NSArray*  subSelectors;

- (instancetype)initWithSubSelectors:(NSArray*)subSelectors;

@end
