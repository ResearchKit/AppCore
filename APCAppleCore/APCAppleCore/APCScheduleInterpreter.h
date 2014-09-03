//
//  APCScheduleInterpreter.h
//  APCAppleCore
//
//  Created by Justin Warmkessel on 9/2/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APCScheduleInterpreter : NSObject

- (NSMutableArray *)taskDates:(NSString *)expression;

@end

