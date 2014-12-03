//
//  APCResult+Bridge.h
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 11/20/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <APCAppleCore/APCAppleCore.h>

@interface APCResult (Bridge)

@property (nonatomic, readonly) NSURL * archiveURL;
- (void) uploadToBridgeOnCompletion: (void (^)(NSError * error)) completionBlock;

@end
