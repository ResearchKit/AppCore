//
//  APCDataSubstrate.h
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 8/25/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@class  NSManagedObjectContext, NSManagedObjectModel;
@interface APCDataSubstrate : NSObject


/*********************************************************************************/
#pragma mark - Properties
/*********************************************************************************/
@property (nonatomic, strong) NSManagedObjectContext * mainContext;
@property (nonatomic, strong) NSManagedObjectContext * persistentContext;

/*********************************************************************************/
#pragma mark - Initializers/Methods
/*********************************************************************************/
- (instancetype)initWithPersistentStorePath: (NSString*) storePath additionalModels:(NSManagedObjectModel *)mergedModels;

@end
