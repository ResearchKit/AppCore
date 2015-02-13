//
//  APCFoodInsight.h
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCAppCore.h"

@protocol APCFoodInsightDelegate <NSObject>

- (void)didCompleteFoodInsight:(NSDictionary *)insight;

@end

@interface APCFoodInsight : NSObject

@property (nonatomic, weak) id <APCFoodInsightDelegate> delegate;

- (instancetype)initFoodInsightForSampleType:(HKSampleType *)sample
                                        unit:(HKUnit *)unit;

- (NSArray *)foodInsights;

@end
