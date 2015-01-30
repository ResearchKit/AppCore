//
//  APCGenericDataTracker.h
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class APCDataTracker;
@protocol APCDataTrackerDelegate <NSObject>
- (void) APCDataTracker: (APCDataTracker*) tracker hasNewData: (NSArray*) dataArray; //Array of Arrays. Individual array should have the same number of items as the columnNames array.
@end

@interface APCDataTracker : NSObject

@property (nonatomic, readonly) NSString * identifier;
@property (nonatomic, weak) id<APCDataTrackerDelegate> delegate;

@property (nonatomic) long long sizeThreshold;
@property (nonatomic) NSTimeInterval stalenessInterval;

- (instancetype) initWithIdentifier:(NSString *)identifier;

- (NSArray*) columnNames;

@end
