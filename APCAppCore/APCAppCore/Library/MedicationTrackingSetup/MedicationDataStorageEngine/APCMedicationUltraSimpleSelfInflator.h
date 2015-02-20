//
//  APCMedicationUltraSimpleSelfInflator.h
//  AppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

//#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface APCMedicationUltraSimpleSelfInflator : NSObject

/**
 Looks for the specified filename in the bundle,
 and attempt to inflate a bunch of instances of this
 class from the array of dictionaries in that file.
 */
+ (NSArray *) inflatedItemsFromPlistFileWithName: (NSString *) fileName;

+ (instancetype) inflateFromPlistEntry: (NSDictionary *) plistEntry;

/**
 Subclasses:  Please use -init as your Designated Initializer.
 This super implementation does nothing.  However, your -init
 method will be called by initWithPlistEntry:, which is the
 point of this class.
 */
- (id) init NS_DESIGNATED_INITIALIZER;

- (id) initWithPlistEntry: (NSDictionary *) plistEntry;

@end
