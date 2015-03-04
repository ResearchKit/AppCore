// 
//  APCDataMonitor+Bridge.h 
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
//
 
#import "APCDataMonitor.h"

@interface APCDataMonitor (Bridge)
- (void) refreshFromBridgeOnCompletion: (void (^)(NSError * error)) completionBlock;
- (void) batchUploadDataToBridgeOnCompletion: (void (^)(NSError * error)) completionBlock;
- (void) uploadZipFile:(NSString*) path onCompletion: (void (^)(NSError * error)) completionBlock;
@end
