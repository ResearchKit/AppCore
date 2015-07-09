// 
//  APCMotionHistoryReporter.m 
//  APCAppCore 
// 
// Copyright (c) 2015, Apple Inc. All rights reserved. 
// 
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
// 
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
// 
// 2.  Redistributions in binary form must reproduce the above copyright notice, 
// this list of conditions and the following disclaimer in the documentation and/or 
// other materials provided with the distribution. 
// 
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors 
// may be used to endorse or promote products derived from this software without 
// specific prior written permission. No license is granted to the trademarks of 
// the copyright holders even if such marks are included in this software. 
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE 
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
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

@property (copy, nonatomic) APCMotionHistoryReporterCallback doneCallback;

@end


@implementation APCMotionHistoryReporter

static APCMotionHistoryReporter __strong *sharedInstance = nil;



+ (APCMotionHistoryReporter *)sharedInstance {
    
    //Thread-Safe version
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        sharedInstance = [self new];
        
    });
    return sharedInstance;
}


- (id)init {
    self = [super init];
    if (self) {
        self->motionActivityManager = [CMMotionActivityManager new];
        self->motionReport = [NSMutableArray new];
        self->isTheDataReady = false;
    }
    return self;
}

- (void)startMotionCoProcessorDataFrom:(NSDate * __nonnull)startDate andEndDate:(NSDate * __nonnull)endDate andNumberOfDays:(NSInteger)numberOfDays {
	[self startMotionCoProcessorDataFrom:startDate andEndDate:endDate andNumberOfDays:numberOfDays callback:^(NSArray *reports, NSError *error) {
		if (error) {
			NSLog(@"ERROR: %@", error.localizedDescription);
		}
		else {
			[[NSNotificationCenter defaultCenter] postNotificationName:APCMotionHistoryReporterDoneNotification object:nil];
		}
	}];
}

- (void)startMotionCoProcessorDataFrom:(NSDate * __nonnull)startDate andEndDate:(NSDate * __nonnull)endDate andNumberOfDays:(NSInteger)numberOfDays callback:(APCMotionHistoryReporterCallback __nonnull)callback {
	NSParameterAssert(startDate);
	NSParameterAssert(endDate);
	NSParameterAssert(callback);
	if (_doneCallback) {
		callback(nil, [NSError errorWithDomain:@"APCAppCoreErrorDomain" code:51 userInfo:@{NSLocalizedDescriptionKey: @"Motion History Reporter is already processing motion history, wait for it to complete"}]);
		return;
	}
	
	[motionReport removeAllObjects];
	isTheDataReady = false;
	
	self.doneCallback = callback;
	[self getMotionCoProcessorDataFrom:startDate andEndDate:endDate andNumberOfDays:numberOfDays];
}

//iOS is collecting activity data in the background whether you ask for it or not, so this feature will give you activity data even if your application as only been installed very recently.
-(void)getMotionCoProcessorDataFrom:(NSDate * __nonnull)startDate andEndDate:(NSDate * __nonnull)endDate andNumberOfDays:(NSInteger)numberOfDays
{
	NSParameterAssert(startDate);
	NSParameterAssert(endDate);
	if (numberOfDays == 0) {
		isTheDataReady = true;
		[self callDoneCallbackWithReports:[motionReport copy] error:nil];
		return;
	}
	
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
                                                     
                                                          NSDate *lastActivity_started;

                                                          NSTimeInterval totalUnknownTime = 0.0;
                                                          
                                                          NSTimeInterval totalRunningTime = 0.0;
                                                          NSTimeInterval totalSleepTime = 0.0;
                                                          NSTimeInterval totalLightActivityTime = 0.0;
                                                          NSTimeInterval totalSedentaryTime = 0.0;
                                                          NSTimeInterval totalModerateTime = 0.0;
                                                          
                                                          
                                                          NSTimeInterval totalModerateActivityTime = 0.0;
                                                          NSTimeInterval totalVigorousActivityTime = 0.0;
                                                           
                                                          //CMMotionActivity is generated every time the state of motion changes. Assuming this, given two CMMMotionActivity objects you can calculate the duration between the two events thereby determining how long the activity of stationary/walking/running/driving/uknowning was.
                                                          
                                                          //Setting lastMotionActivityType to 0 from this point on we will use the emum.
                                                          NSInteger lastMotionActivityType = 0;
                                                          
                                                           NSMutableArray *motionDayValues = [NSMutableArray new];
                                                          
                                                          for(CMMotionActivity *activity in activities)
                                                          {
                                                              
                                                              NSTimeInterval activityLengthTime = 0.0;
                                                              activityLengthTime = fabs([lastActivity_started timeIntervalSinceDate:activity.startDate]);
                                                              

                                                              
                                                              NSDate *midnight = [[NSCalendar currentCalendar] dateBySettingHour:0
                                                                                                                   minute:0
                                                                                                                   second:0
                                                                                                                   ofDate:newEndDate
                                                                                                                  options:0];

                                                              NSTimeInterval removeThis = 0;
                                                              
                                                              if (![[midnight laterDate:activity.startDate] isEqualToDate:midnight]|| [midnight isEqualToDate:activity.startDate]) {
                                                                  
                                                                  if (![[lastActivity_started laterDate: midnight] isEqualToDate:lastActivity_started] && ![midnight isEqualToDate:lastActivity_started]) {
                                                                      //Get time interval of the potentially overlapping date
                                                                      removeThis = [midnight timeIntervalSinceDate:lastActivity_started];
                                                                      
                                                                      activityLengthTime = activityLengthTime - removeThis;
                                                                  }
                                                                  
                                                                  //Look for walking moderate and high confidence
                                                                  //Cycling any confidence
                                                                  //Running any confidence
                                                                  
                                                                  if((lastMotionActivityType == MotionActivityWalking && activity.confidence == CMMotionActivityConfidenceHigh) || (lastMotionActivityType == MotionActivityWalking && activity.confidence == CMMotionActivityConfidenceMedium))
                                                                  {

                                                                      if(activity.confidence == CMMotionActivityConfidenceMedium || activity.confidence == CMMotionActivityConfidenceHigh)
                                                                      {
                                                                          totalModerateActivityTime += activityLengthTime;
                                                                      }
                                                                      
                                                                  } else if (lastMotionActivityType == MotionActivityRunning || lastMotionActivityType == MotionActivityCycling) {
                                                                      
                                                                      totalVigorousActivityTime += activityLengthTime;
                                                                      
                                                                  }
                                                              }
                                                                  
                                                              //this will skip the first activity as the lastMotionActivityType will be zero which is not in the enum
                                                              if((lastMotionActivityType == MotionActivityWalking && activity.confidence == CMMotionActivityConfidenceHigh) || (lastMotionActivityType == MotionActivityWalking && activity.confidence == CMMotionActivityConfidenceMedium))
                                                              {
                                                                  //now we need to figure out if its sleep time
                                                                  // anything over 3 hours will be sleep time
                                                                  NSTimeInterval activityLength = 0.0;
                                                                  
                                                                  activityLength = fabs([lastActivity_started timeIntervalSinceDate:activity.startDate]);
                                                                  
                                                                  if(activity.confidence == CMMotionActivityConfidenceMedium || activity.confidence == CMMotionActivityConfidenceHigh) // 45 seconds
                                                                  {
                                                                      totalModerateTime += fabs(activityLength);
                                                                   
                                                                  }
                                                                
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
                                                                
                                                                  
                                                                  if(activityLength >= 10800) // 3 hours in seconds
                                                                  {
                                                                      totalSleepTime += fabs([lastActivity_started timeIntervalSinceDate:activity.startDate]);
                                                                      
                                                                  }
                                                                  else
                                                                  {
                                                                      totalSedentaryTime += fabs([lastActivity_started timeIntervalSinceDate:activity.startDate]);
                                                                     
                                                                  }
                                                                  
                                                              }
                                                              else if(lastMotionActivityType == MotionActivityUnknown)
                                                              {
																  NSTimeInterval lastActivityDuration = fabs([lastActivity_started timeIntervalSinceDate:activity.startDate]);
																  
                                                                  if (activity.stationary)
                                                                  {
                                                                      totalSedentaryTime += lastActivityDuration;
                                                                      lastActivity_started = activity.startDate;
                                                                  }
                                                                  else if (activity.walking && activity.confidence == CMMotionActivityConfidenceLow)
                                                                  {
                                                                      totalLightActivityTime += lastActivityDuration;
                                                                      lastActivity_started = activity.startDate;
                                                                  }
                                                                  else if (activity.walking)
                                                                  {
																	  totalModerateTime += lastActivityDuration;
                                                                      lastActivity_started = activity.startDate;
                                                                  }
                                                                  else if (activity.running)
                                                                  {
																	  totalRunningTime += lastActivityDuration;
                                                                      lastActivity_started = activity.startDate;
                                                                  }
                                                                  
                                                                  else if (activity.cycling)
                                                                  {
																	  totalRunningTime += lastActivityDuration;
                                                                      lastActivity_started = activity.startDate;
                                                                  }
                                                                  else if (activity.automotive)
                                                                  {
																	  totalSedentaryTime += lastActivityDuration;
                                                                      lastActivity_started = activity.startDate;
                                                                  }
                                                                  
                                                                  totalUnknownTime += fabs([lastActivity_started timeIntervalSinceDate:activity.startDate]);
                                                                  
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
                                                              
                                                          }

                                                          
                                                          APCMotionHistoryData * motionHistoryVigorous = [APCMotionHistoryData new];
                                                          motionHistoryVigorous.activityType = ActivityTypeRunning;
                                                          motionHistoryVigorous.timeInterval = totalRunningTime;
                                                          [motionDayValues addObject:motionHistoryVigorous];
                                                          
                                                          
                                                          
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
                                                          
                                                          APCMotionHistoryData * motionHistoryDataUnknown = [APCMotionHistoryData new];
                                                          motionHistoryDataUnknown.activityType = ActivityTypeUnknown;
                                                          motionHistoryDataUnknown.timeInterval = totalUnknownTime;
                                                          [motionDayValues addObject:motionHistoryDataUnknown];
                                                          
                                                          APCMotionHistoryData * motionHistoryDataSleeping = [APCMotionHistoryData new];
                                                          motionHistoryDataSleeping.activityType = ActivityTypeSleeping;
                                                          motionHistoryDataSleeping.timeInterval = totalSleepTime;
                                                          [motionDayValues addObject:motionHistoryDataSleeping];
                                                          
                                                          APCMotionHistoryData * motionHistoryActiveMinutesVigorous = [APCMotionHistoryData new];
                                                          motionHistoryActiveMinutesVigorous.activityType = ActivityTypeAutomotive;
                                                          motionHistoryActiveMinutesVigorous.timeInterval = totalVigorousActivityTime;
                                                          [motionDayValues addObject:motionHistoryActiveMinutesVigorous];
                                                          
                                                          APCMotionHistoryData * motionHistoryActiveMinutesModerate = [APCMotionHistoryData new];
                                                          motionHistoryActiveMinutesModerate.activityType = ActivityTypeCycling;
                                                          motionHistoryActiveMinutesModerate.timeInterval = totalModerateActivityTime;
                                                          [motionDayValues addObject:motionHistoryActiveMinutesModerate];
                                                          
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
                                                          
                                        
                                                          
    }];
}

- (void)callDoneCallbackWithReports:(NSArray * __nullable )reports error:(NSError * __nullable )error {
	if (_doneCallback) {
		_doneCallback(reports, error);
		self.doneCallback = nil;
	}
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
