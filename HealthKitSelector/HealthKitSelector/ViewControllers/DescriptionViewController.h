//
//  DescriptionViewController.h
//  HealthKitSelector
//
//  Created by Dzianis Asanovich on 10/21/14.
//  Copyright (c) 2014 Dzianis Asanovich. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <HealthKit/HealthKit.h>

@interface DescriptionViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) HKSample * sample;

@end
