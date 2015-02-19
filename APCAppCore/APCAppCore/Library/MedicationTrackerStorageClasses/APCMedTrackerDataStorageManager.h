//
//  APCMedTrackerDataStorageManager.h
//  APCAppCore
//
//  Created by Ron Conescu on 2/18/15.
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APCMedTrackerInflatableItem+Helper.h"

@interface APCMedTrackerDataStorageManager : NSObject

+ (void) reloadPredefinedItemsFromPlistFilesUsingQueue: (NSOperationQueue *) queue
                                     andDoThisWhenDone: (APCMedTrackerFileLoadCallback) callbackBlock;

@end
