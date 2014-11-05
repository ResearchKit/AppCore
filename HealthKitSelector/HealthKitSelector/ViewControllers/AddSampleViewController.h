//
//  AddQuantityViewController.h
//  HealthKitSelector
//
//  Created by Dzianis Asanovich on 10/22/14.
//  Copyright (c) 2014 Dzianis Asanovich. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <HealthKit/HealthKit.h>

@protocol HHReturnSample

- (void) newSample: (HKSample *) sample;
- (void) newWorkoutEvents: (NSArray *) newWorkouts;

@end

@interface AddSampleViewController : UIViewController<UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, HHReturnSample>

@property (nonatomic, strong) NSString * identifier;
@property (nonatomic, weak) id<HHReturnSample> returnSampleDelegate;

@property (nonatomic) BOOL simpleQuantity;

@end
