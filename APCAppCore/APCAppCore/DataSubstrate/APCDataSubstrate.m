// 
//  APCDataSubstrate.m 
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
 
#import "APCDataSubstrate.h"
#import "APCConstants.h"
#import "APCUser.h"
#import "APCAppDelegate.h"		// should be replaced
#import "APCLog.h"

#import "APCDataSubstrate+CoreData.h"
#import "APCDataSubstrate+HealthKit.h"

#import "NSDate+Helper.h"
#import "APCTask+AddOn.h"
#import "APCSchedule+AddOn.h"
#import "APCScheduledTask+AddOn.h"
#import "NSError+APCAdditions.h"

static int dateCheckTimeInterval = 60;


@interface APCDataSubstrate ()

@property (strong, nonatomic) NSTimer *dateChangeTestTimer;//refreshes Activities if the date crosses midnight.
@property (strong, nonatomic) NSDate *tomorrowAtMidnight;

@end

@implementation APCDataSubstrate

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithPersistentStorePath:(NSString *)storePath
						   additionalModels:(NSManagedObjectModel *)mergedModels
                            studyIdentifier:(NSString *)__unused studyIdentifier
{
    self = [super init];
    if (self) {
        [self setUpCoreDataStackWithPersistentStorePath:storePath additionalModels:mergedModels];
        [self setUpCurrentUser:self.persistentContext];
        [self setUpHealthKit];
        [self setupParameters];
        [self setupNotifications];
    }
    return self;
}

- (void)setUpCurrentUser:(NSManagedObjectContext *)context
{
    if (!_currentUser) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _currentUser = [[APCUser alloc] initWithContext:context];
        });
    }
}

- (void)setupParameters
{
    self.parameters = [[APCParameters alloc] initWithFileName:@"APCParameters.json"];
    [self.parameters setDelegate:self];
}

- (void)setupNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(instantiateTimer:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(instantiateTimer:) name:UIApplicationDidFinishLaunchingNotification object:nil];
}


#pragma mark - Properties & Methods meant only for Categories

- (void)parameters:(APCParameters *)__unused parameters didFailWithError:(NSError *)error
{
    NSAssert(error, @"parameters are not loaded");
}


#pragma mark - Date Change Test Timer

- (void)instantiateTimer:(NSNotification *)__unused notification
{
    self.tomorrowAtMidnight = [NSDate tomorrowAtMidnight];
    self.dateChangeTestTimer = [NSTimer scheduledTimerWithTimeInterval:dateCheckTimeInterval target:self selector:@selector(didDateCrossMidnight:) userInfo:nil repeats:YES];
}

- (void)didDateCrossMidnight:(NSNotification *)__unused notification
{
    if ([[NSDate new] compare:self.tomorrowAtMidnight] == NSOrderedDescending || [[NSDate new] compare:self.tomorrowAtMidnight] == NSOrderedSame) {
        [[NSNotificationCenter defaultCenter] postNotificationName:APCDayChangedNotification object:nil];
        self.tomorrowAtMidnight = [NSDate tomorrowAtMidnight];
    }
}

@end
