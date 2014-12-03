//
//  APCDataMonitor+Bridge.h
//  APCAppCore
//
//  Created by Dhanush Balachandran on 12/2/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCDataMonitor.h"

@interface APCDataMonitor (Bridge)

- (void) refreshFromBridgeOnCompletion: (void (^)(NSError * error)) completionBlock;
- (void) batchUploadDataToBridgeOnCompletion: (void (^)(NSError * error)) completionBlock;

@end
