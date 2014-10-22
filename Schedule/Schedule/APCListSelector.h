//
//  APCListSelector.h
//  Schedule
//
//  Created by Edward Cessna on 9/24/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCTimeSelector.h"
#import "APCPointSelector.h"

//  Disjunction selector: if any of the sub-selectors matches then the selector matches

@interface APCListSelector : APCTimeSelector

@property (nonatomic, strong) NSArray*  subSelectors;

- (instancetype)initWithSubSelectors:(NSArray*)subSelectors;

@end
