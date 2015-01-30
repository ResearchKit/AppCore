//
//  APCPassiveDataCollector.h
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APCDataTracker.h"

@interface APCPassiveDataCollector : NSObject

-(void) addTracker: (APCDataTracker*) tracker;

- (void) flush:(NSString*) trackerIdentifier; //Packages the data collected so far as encrypted zip.

@end
