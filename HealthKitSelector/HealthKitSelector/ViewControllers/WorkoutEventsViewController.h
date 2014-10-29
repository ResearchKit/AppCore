//
//  WorkoutEventsViewController.h
//  HealthKitSelector
//
//  Created by Dzianis Asanovich on 10/23/14.
//  Copyright (c) 2014 Dzianis Asanovich. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddSampleViewController.h"

@interface WorkoutEventsViewController : UITableViewController

@property (nonatomic, strong) NSArray * workoutEvents;
@property (nonatomic, weak) id<HHReturnSample> returnSampleDelegate;

@end
