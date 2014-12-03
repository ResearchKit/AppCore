// 
//  APCDataMonitor+Bridge.h 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "APCDataMonitor.h"

@interface APCDataMonitor (Bridge)

- (void) refreshFromBridgeOnCompletion: (void (^)(NSError * error)) completionBlock;
- (void) batchUploadDataToBridgeOnCompletion: (void (^)(NSError * error)) completionBlock;

@end
