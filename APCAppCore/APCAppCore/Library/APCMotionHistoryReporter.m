//
//  APCMotionHistoryReporter.m
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCMotionHistoryReporter.h"
#import <CoreMotion/CoreMotion.h>
#import "APCMotionHistoryData.h"
#import "APCConstants.h"

typedef NS_ENUM(NSInteger, MotionActivity)
{
    MotionActivityStationary = 1,
    MotionActivityWalking,
    MotionActivityRunning,
    MotionActivityAutomotive,
    MotionActivityCycling,
    MotionActivityUnknown
};


@interface APCMotionHistoryReporter()
{
    CMMotionActivityManager * motionActivityManager;
    CMMotionManager * motionManager;
    NSMutableArray *motionReport;
    BOOL isTheDataReady;
    
}

@end

@implementation APCMotionHistoryReporter

static APCMotionHistoryReporter __strong *sharedInstance = nil;



+(APCMotionHistoryReporter *) sharedInstance {
    
    //Thread-Safe version
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        sharedInstance = [self new];
        
    });
    
    
    return sharedInstance;
}


- (id)init
{
    self = [super init];
    if(self) {
        self->motionActivityManager = [CMMotionActivityManager new];
        self->motionReport = [NSMutableArray new];
        self->isTheDataReady = false;
        
    }
    
    return self;
}




-(void)startMotionCoProcessorDataFrom:(NSDate *)startDate andEndDate:(NSDate *)endDate andNumberOfDays:(NSInteger)numberOfDays
{
    [motionReport removeAllObjects];
    isTheDataReady = false;
    
    [self getMotionCoProcessorDataFrom:startDate andEndDate:endDate andNumberOfDays:numberOfDays];
}



//iOS is collecting activity data in the background whether you ask for it or not, so this feature will give you activity data even if your application as only been installed very recently.
-(void)getMotionCoProcessorDataFrom:(NSDate *)startDate andEndDate:(NSDate *)endDate andNumberOfDays:(NSInteger)numberOfDays
{
    
    NSInteger               numberOfDaysBack = numberOfDays * -1;
    NSDateComponents        *components = [[NSDateComponents alloc] init];
    
    [components setDay:numberOfDaysBack];
    
    NSDate                  *newStartDate = [[NSCalendar currentCalendar] dateByAddingComponents:components
                                                                                          toDate:startDate
                                                                                         options:0];
    
    NSInteger               numberOfDaysBackForEndDate = numberOfDays * -1;
    
    NSDateComponents        *endDateComponent = [[NSDateComponents alloc] init];
    [endDateComponent setDay:numberOfDaysBackForEndDate];
    
    NSDate                  *newEndDate = [[NSCalendar currentCalendar] dateByAddingComponents:endDateComponent
                                                                                        toDate:endDate
                                                                                       options:0];
  
    
    [motionActivityManager queryActivityStartingFromDate:newStartDate
                                                       toDate:newEndDate
                                                      toQueue:[NSOperationQueue new]
                                                  withHandler:^(NSArray *activities, NSError * __unused error) {
                                                     
                                                      if (numberOfDays > 0)
                                                      {
                                                          NSDate *lastActivity_started;
                                                          
                                                          NSTimeInterval totalSleepTime = 0.0;
                                                          NSTimeInterval totalStationaryTime = 0.0;
                                                          NSTimeInterval totalLightActivityTime = 0.0;
                                                          NSTimeInterval totalWalkingTime = 0.0;
                                                          NSTimeInterval totalRunningTime = 0.0;
                                                          NSTimeInterval totalAutomotiveTime = 0.0;
                                                          NSTimeInterval totalUnknownTime = 0.0;
                                                          NSTimeInterval totalCyclingTime = 0.0;
                                                          NSTimeInterval totalAllocatedTime = 0.0;
                                                          
                                                          NSTimeInterval totalSedentaryTime = 0.0;
                                                          NSTimeInterval totalModerateTime = 0.0;
                                                          
                                                          
                                                          
                                                          
                                                          //CMMotionActivity is generated every time the state of motion changes. Assuming this, given two CMMMotionActivity objects you can calculate the duration between the two events thereby determining how long the activity of stationary/walking/running/driving/uknowning was.
                                                          
                                                          //Setting lastMotionActivityType to 0 from this point on we will use the emum.
                                                          NSInteger lastMotionActivityType = 0;
                                                          
                                                           NSMutableArray *motionDayValues = [NSMutableArray new];
                                                          
                                                          for(CMMotionActivity *activity in activities)
                                                          {
                                                              
                                                              //get anactivity based on high Confidence
                                                              //if (activity.confidence == CMMotionActivityConfidenceHigh){
                                                                
                                                                  
                                                                  
                                                                  //this will skip the first activity as the lastMotionActivityType will be zero which is not in the enum
                                                                  if((lastMotionActivityType == MotionActivityWalking && activity.confidence == CMMotionActivityConfidenceHigh) || (lastMotionActivityType == MotionActivityWalking && activity.confidence == CMMotionActivityConfidenceMedium))
                                                                  {
                                                                      //now we need to figure out if its sleep time
                                                                      // anything over 3 hours will be sleep time
                                                                      NSTimeInterval activityLength = 0.0;
                                                                      
                                                                      activityLength = fabs([lastActivity_started timeIntervalSinceDate:activity.startDate]);
                                                                      
                                                                      if(activity.confidence == CMMotionActivityConfidenceMedium || activity.confidence == CMMotionActivityConfidenceHigh) // 45 seconds
                                                                      {
                                                                          totalModerateTime += fabs([lastActivity_started timeIntervalSinceDate:activity.startDate]);
                                                                       
                                                                      }

                                                                      //totalWalkingTime +=  fabs([lastActivity_started timeIntervalSinceDate:activity.startDate]);
                                                                    
                                                                  }
                                                                  else if(lastMotionActivityType == MotionActivityWalking && activity.confidence == CMMotionActivityConfidenceLow)
                                                                  {
                                                                      totalLightActivityTime += fabs([lastActivity_started timeIntervalSinceDate:activity.startDate]);
                                                                      
                                                                  }
                                                                  
                                                                  else if(lastMotionActivityType == MotionActivityRunning)
                                                                  {
                                                                      totalRunningTime += fabs([lastActivity_started timeIntervalSinceDate:activity.startDate]);
                                                                      
                                                                  }
                                                                  else if(lastMotionActivityType == MotionActivityAutomotive)
                                                                  {
                                                                      totalSedentaryTime += fabs([lastActivity_started timeIntervalSinceDate:activity.startDate]);
                                                                     
                                                                  }
                                                                  else if(lastMotionActivityType == MotionActivityUnknown)
                                                                  {
                                                                      if (activity.stationary)
                                                                      {
                                                                          totalSedentaryTime += fabs([lastActivity_started timeIntervalSinceDate:activity.startDate]);
                                                                      }
                                                                      else if (activity.walking)
                                                                      {
                                                                          totalLightActivityTime += fabs([lastActivity_started timeIntervalSinceDate:activity.startDate]);
                                                                      }
                                                                      else if (activity.running)
                                                                      {
                                                                          totalRunningTime += fabs([lastActivity_started timeIntervalSinceDate:activity.startDate]);
                                                                      }
                                                                      
                                                                      else if (activity.cycling)
                                                                      {
                                                                          totalRunningTime += fabs([lastActivity_started timeIntervalSinceDate:activity.startDate]);
                                                                      }
                                                                      else if (activity.automotive)
                                                                      {
                                                                          totalSedentaryTime += fabs([lastActivity_started timeIntervalSinceDate:activity.startDate]);
                                                                      }
                                                                      
                                                                      totalUnknownTime += fabs([lastActivity_started timeIntervalSinceDate:activity.startDate]);
                                                                      
                                                                  }
                                                                  else if(lastMotionActivityType == MotionActivityCycling)
                                                                  {
                                                                      totalRunningTime += fabs([lastActivity_started timeIntervalSinceDate:activity.startDate]);
                                                                     
                                                                  }
                                                                  else if(lastMotionActivityType == MotionActivityStationary)
                                                                  {
                                                                      
                                                                      //now we need to figure out if its sleep time
                                                                      // anything over 3 hours will be sleep time
                                                                      NSTimeInterval activityLength = 0.0;
                                                                      
                                                                      activityLength = fabs([lastActivity_started timeIntervalSinceDate:activity.startDate]);
                                                                    
                                                                      
                                                                      if(activityLength >= 10800 && activity.confidence == CMMotionActivityConfidenceHigh) // 3 hours in seconds
                                                                      {
                                                                          totalSleepTime += fabs([lastActivity_started timeIntervalSinceDate:activity.startDate]);
                                                                          
                                                                      }
                                                                      else
                                                                      {
                                                                          totalSedentaryTime += fabs([lastActivity_started timeIntervalSinceDate:activity.startDate]);
                                                                         
                                                                      }
                                                                      
                                                                  }
                                                                  
                                                                  
                                                                  if (activity.stationary){
                                                                     
                                                                      lastMotionActivityType = MotionActivityStationary;
                                                                      lastActivity_started = activity.startDate;
                                                                      
                                                                  }
                                                                  else if (activity.walking)
                                                                  {
                                                                      lastMotionActivityType = MotionActivityWalking;
                                                                      lastActivity_started = activity.startDate;
                                                                      
                                                                  }
                                                                  
                                                                  else if (activity.walking && activity.confidence == CMMotionActivityConfidenceLow)
                                                                  {
                                                                      lastMotionActivityType = MotionActivityWalking;
                                                                      lastActivity_started = activity.startDate;
                                                                      
                                                                  }
                                                                  
                                                                  else if (activity.running){
                                                                      
                                                                      lastMotionActivityType = MotionActivityRunning;
                                                                      lastActivity_started = activity.startDate;
                                                                      
                                                                  }
                                                                  else if (activity.automotive){
                                                                      
                                                                      lastMotionActivityType = MotionActivityAutomotive;
                                                                      lastActivity_started = activity.startDate;
                                                                      
                                                                  }
                                                                  else if (activity.cycling){
                                                                     
                                                                      lastMotionActivityType = MotionActivityCycling;
                                                                      lastActivity_started = activity.startDate;
                                                                      
                                                                  }
                                                                  else
                                                                  {
                                                                      lastMotionActivityType = MotionActivityUnknown;
                                                                      lastActivity_started = activity.startDate;
                                                                      
                                                                  }
                                                              //}
                                                          }
                                                          
                                                          
                                                          totalAllocatedTime = totalSleepTime + totalWalkingTime + totalRunningTime + totalAutomotiveTime + totalUnknownTime + totalStationaryTime;
                                                         
                                           
                                                          APCMotionHistoryData * motionHistoryDataStationary = [APCMotionHistoryData new];
                                                          motionHistoryDataStationary.activityType = ActivityTypeStationary;
                                                          motionHistoryDataStationary.timeInterval = totalStationaryTime;
                                                          [motionDayValues addObject:motionHistoryDataStationary];
                                                          
                                                         
                                                          APCMotionHistoryData * motionHistoryDataWalking = [APCMotionHistoryData new];
                                                          motionHistoryDataWalking.activityType = ActivityTypeWalking;
                                                          motionHistoryDataWalking.timeInterval = totalWalkingTime;
                                                          [motionDayValues addObject:motionHistoryDataWalking];
                                                          
                                                          APCMotionHistoryData * motionHistoryLightActivity = [APCMotionHistoryData new];
                                                          motionHistoryLightActivity.activityType = ActivityTypeLight;
                                                          motionHistoryLightActivity.timeInterval = totalWalkingTime;
                                                          [motionDayValues addObject:motionHistoryLightActivity];
                                                          
                                                          
                                                          APCMotionHistoryData * motionHistoryDataRunning = [APCMotionHistoryData new];
                                                          motionHistoryDataRunning.activityType = ActivityTypeLight;
                                                          motionHistoryDataRunning.timeInterval = totalLightActivityTime;
                                                          [motionDayValues addObject:motionHistoryDataRunning];
                                                          
                                                          APCMotionHistoryData * motionHistoryDataSedentary = [APCMotionHistoryData new];
                                                          motionHistoryDataSedentary.activityType = ActivityTypeSedentary;
                                                          motionHistoryDataSedentary.timeInterval = totalSedentaryTime;
                                                          [motionDayValues addObject:motionHistoryDataSedentary];
                                                          
                                                          APCMotionHistoryData * motionHistoryDataModerate = [APCMotionHistoryData new];
                                                          motionHistoryDataModerate.activityType = ActivityTypeModerate;
                                                          motionHistoryDataModerate.timeInterval = totalModerateTime;
                                                          [motionDayValues addObject:motionHistoryDataModerate];
                                                          

                                                          APCMotionHistoryData * motionHistoryDataAutomotive = [APCMotionHistoryData new];
                                                          motionHistoryDataAutomotive.activityType = ActivityTypeAutomotive;
                                                          motionHistoryDataAutomotive.timeInterval = totalAutomotiveTime;
                                                          [motionDayValues addObject:motionHistoryDataAutomotive];
                                                          
                                                          
                                                          
                                                         
                                                          APCMotionHistoryData * motionHistoryDataCycling = [APCMotionHistoryData new];
                                                          motionHistoryDataCycling.activityType = ActivityTypeCycling;
                                                          motionHistoryDataCycling.timeInterval = totalCyclingTime;
                                                          [motionDayValues addObject:motionHistoryDataCycling];
                                                          
                                                          
                                                         
                                                          APCMotionHistoryData * motionHistoryDataUnknown = [APCMotionHistoryData new];
                                                          motionHistoryDataUnknown.activityType = ActivityTypeUnknown;
                                                          motionHistoryDataUnknown.timeInterval = totalUnknownTime;
                                                          [motionDayValues addObject:motionHistoryDataUnknown];
                                                          
                                                          
                                                          
                                                          APCMotionHistoryData * motionHistoryDataSleeping = [APCMotionHistoryData new];
                                                          motionHistoryDataSleeping.activityType = ActivityTypeSleeping;
                                                          motionHistoryDataSleeping.timeInterval = totalSleepTime;
                                                          [motionDayValues addObject:motionHistoryDataSleeping];
                                                          
                                                          [motionReport addObject:motionDayValues];
                                                          
                                                          //Different start date and end date
                                                          NSDateComponents *numberOfDaysFromStartDate = [[NSCalendar currentCalendar] components:NSCalendarUnitDay
                                                                                                                                        fromDate:startDate
                                                                                                                                          toDate:[NSDate date]
                                                                                                                                         options:NSCalendarWrapComponents];
                                                          
                                                          //numberOfDaysFromStartDate provides the difference of days from now to start of task and therefore if there is no difference we are only getting data for one day.
                                                          numberOfDaysFromStartDate.day += 1;
                                                          
                                                          NSDateComponents *dateComponent = [[NSDateComponents alloc] init];
                                                          [dateComponent setDay:-1];
                                                          NSDate *newStartDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponent
                                                                                                                               toDate:endDate
                                                                                                                              options:0];
                                                          
                                                         
                                                          [self getMotionCoProcessorDataFrom:newStartDate
                                                                                  andEndDate:endDate
                                                                             andNumberOfDays:numberOfDays - 1];
                                                          
                                        
                                                          
                                                      }
                                                      
                                                      if(numberOfDays == 0)
                                                      {
                                                          isTheDataReady = true;
                                                          [[NSNotificationCenter defaultCenter] postNotificationName:APCMotionHistoryReporterDoneNotification object:self];
                                                          
                                                      }
                                                                                                      
        
    }];
}



-(NSArray*) retrieveMotionReport
{
    //Return the NSMutableArray as an immutable array
    return [motionReport copy];
}

-(BOOL)isDataReady{
    return isTheDataReady;
}

@end
