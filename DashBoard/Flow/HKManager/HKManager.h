
#import <Foundation/Foundation.h>

@import HealthKit;

@interface HKManager : NSObject {
    HKHealthStore *store;
}

+ (instancetype)sharedManager;

- (void)authorizeWithCompletion:(void (^)(NSError *error))compeltion;
- (void)storeHeartBeatsAtMinute:(double)beats
                     startDate:(NSDate *)startDate endDate:(NSDate *)endDate
                    completion:(void (^)(NSError *error))compeltion;

- (void) heartBeatsCompletion:(void (^)(NSArray *result, NSError *error))compeltion;

@end


@interface NSError (HKManager)

@property (readonly) NSString *hkManagerErrorMessage;

+ (NSError *)hkManagerErrorWithMessage:(NSString *)errorMessage;

@end