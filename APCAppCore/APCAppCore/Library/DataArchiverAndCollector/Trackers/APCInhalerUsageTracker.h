//
//  APCInhalerUsageTracker.h
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <APCAppCore/APCAppCore.h>

@interface APCInhalerUsageTracker : APCDataTracker
@property (nonatomic, strong) NSString *csvFilename;
@end
