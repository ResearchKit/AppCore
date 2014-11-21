//
//  APCScheduleParser.h
//  Schedule
//
//  Created by Edward Cessna on 10/2/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APCListSelector.h"
#import "APCPointSelector.h"

/*
     digit   :: '0'..'9'
     dow     :: 'a'..'z'
     number  :: digit+ | dow+
     steps   :: number
     range   :: number ( '-' number ) ?
     numspec :: '*' | range
     expr    :: numspec ( '/' steps ) ?
     list    :: expr ( ',' expr ) *

    fields   :: minutesList hoursList dayOfMonthList monthList dayOfWeekList
 */

@interface APCScheduleParser : NSObject

@property (nonatomic, strong) APCTimeSelector*    minuteSelector;
@property (nonatomic, strong) APCTimeSelector*    hourSelector;
@property (nonatomic, strong) APCTimeSelector*    dayOfMonthSelector;
@property (nonatomic, strong) APCTimeSelector*    monthSelector;
@property (nonatomic, strong) APCTimeSelector*    dayOfWeekSelector;
@property (nonatomic, strong) APCTimeSelector*    yearSelector;
@property (nonatomic, assign) BOOL                isRelative;

- (instancetype)initWithExpression:(NSString*)expression;

/**
 *  The validity of the parsed expression.
 *
 *  @return Returns a _YES_ value if the parse is at the _end_ and no errors have been encountered.
 */
- (BOOL)isValidParse;

- (BOOL)parse;

//  Private
- (NSNumber*)numberProduction;
- (NSArray*)rangeProduction;
- (NSNumber*)stepsProduction;
- (NSArray*)numspecProduction;
- (APCPointSelector*)exprProductionForType:(UnitType)unitType;
- (APCListSelector*)listProductionForType:(UnitType)unitType;

@end
