//
//  APCDataResult.h
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 9/12/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "APCResult.h"


@interface APCDataResult : APCResult

@property (nonatomic, retain) NSString * fileName;
@property (nonatomic, retain) NSData * data;

@end
