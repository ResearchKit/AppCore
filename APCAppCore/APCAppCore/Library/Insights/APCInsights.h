//
//  APCInsights.h
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kAPCInsightFactorValueKey;
extern NSString * const kAPCInsightFactorNameKey;
extern NSString * const kAPCInsightDataCollectionIsCompletedNotification;

typedef NS_ENUM(NSUInteger, APCInsightFactors)
{
    APCInsightFactorActivity = 0,
    APCInsightFactorCalories,
    APCInsightFactorSteps,
    APCInsightFactorSugarConsumption,
    APCInsightFactorSugarCalories,
    APCInsightFactorTimeSlept,
    APCInsightFactorCarbohydrateConsumption,
    APCInsightFactorCarbohydrateCalories
};

@protocol APCInsightsDelegate <NSObject>

- (void)didCompleteInsightForFactor:(APCInsightFactors)factor withInsight:(NSDictionary *)insight;

@end

@interface APCInsights : NSObject

@property (nonatomic, weak) id <APCInsightsDelegate> delegate;

@property (nonatomic) BOOL ignoreBaselineOther;
@property (nonatomic, strong) NSString *captionGood;
@property (nonatomic, strong) NSString *captionBad;
@property (nonatomic, strong) NSNumber *valueGood;
@property (nonatomic, strong) NSNumber *valueBad;

- (instancetype)initWithFactor:(APCInsightFactors)factor;

- (instancetype)initWithFactor:(APCInsightFactors)factor
              numberOfReadings:(NSNumber *)readings
                 insightPeriod:(NSNumber *)period
                  baselineHigh:(NSNumber *)baselineHigh
                 baselineOther:(NSNumber *)baselineOther;

- (void)factorInsight;

@end
