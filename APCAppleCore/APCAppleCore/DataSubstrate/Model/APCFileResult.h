//
//  APCFileResult.h
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 9/12/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "APCResult.h"


@interface APCFileResult : APCResult

@property (nonatomic, retain) NSData * file;

@end
