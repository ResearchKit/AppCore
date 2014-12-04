// 
//  APCResult+Bridge.h 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import <APCAppCore/APCAppCore.h>

@interface APCResult (Bridge)

@property (nonatomic, readonly) NSURL * archiveURL;
- (void) uploadToBridgeOnCompletion: (void (^)(NSError * error)) completionBlock;

@end
