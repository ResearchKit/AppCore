// 
//  APCResult+Bridge.h 
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
//
 
#import <APCAppCore/APCAppCore.h>

@interface APCResult (Bridge)

@property (nonatomic, readonly) NSURL * archiveURL;
- (void) uploadToBridgeOnCompletion: (void (^)(NSError * error)) completionBlock;

@end
