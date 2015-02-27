//
//  APCFoodInsight.h
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCAppCore.h"

extern NSString * const kFoodInsightFoodGenericNameKey;
extern NSString * const kFoodInsightFoodNameKey;
extern NSString * const kFoodInsightValueKey;
extern NSString * const kFoodInsightCaloriesValueKey;
extern NSString * const kFoodInsightFrequencyKey;

@protocol APCFoodInsightDelegate <NSObject>

- (void)didCompleteFoodInsightForSampleType:(HKSampleType *)sampleType insight:(NSArray *)foodInsight;

@end

@interface APCFoodInsight : NSObject

@property (nonatomic, weak) id <APCFoodInsightDelegate> delegate;

@property (nonatomic, strong) NSArray *foodHistory;

- (instancetype)initFoodInsightForSampleType:(HKSampleType *)sample
                                        unit:(HKUnit *)unit;

- (void)insight;

@end
