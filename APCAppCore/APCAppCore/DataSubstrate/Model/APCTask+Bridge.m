// 
//  APCTask+Bridge.m 
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
 
#import "APCTask+Bridge.h"
#import "APCSmartSurveyTask.h"
#import "APCAppDelegate.h"
#import "APCLog.h"

#import "APCTask+AddOn.h"
#import "NSManagedObject+APCHelper.h"

#import <ResearchKit/ResearchKit.h>
#import <BridgeSDK/BridgeSDK.h>
#import <Foundation/Foundation.h>

@implementation APCTask (Bridge)

/*********************************************************************************/
#pragma mark - Surveys
/*********************************************************************************/
+ (BOOL) serverDisabled
{
#if DEVELOPMENT
    return YES;
#else
    return ((APCAppDelegate*)[UIApplication sharedApplication].delegate).dataSubstrate.parameters.bypassServer;
#endif
}

+ (void)refreshSurveysOnCompletion: (void (^)(NSError * error)) completionBlock
{
    NSManagedObjectContext * context = ((APCAppDelegate*)[UIApplication sharedApplication].delegate).dataSubstrate.persistentContext;
    NSFetchRequest * request = [APCTask request];
    request.predicate = [NSPredicate predicateWithFormat:@"taskDescription == nil && taskHRef != nil"];
    [context performBlockAndWait:^{
        NSError * error;
        NSArray * unloadedSurveyTasks = [context executeFetchRequest:request error:&error];
        APCLogError2 (error);
        if (unloadedSurveyTasks && unloadedSurveyTasks.count) {
            [unloadedSurveyTasks enumerateObjectsUsingBlock:^(APCTask * task, NSUInteger __unused idx, BOOL * __unused stop) {
                [task loadSurveyOnCompletion:^(NSError *error) {
                    if (error) {
                        if (completionBlock) {
                            completionBlock(error);
                        }
                    }
                    else
                    {
                        if (completionBlock) {
                            completionBlock(nil);
                        }
                    }
                }];
            }];
        }
        else
        {
            if (completionBlock) {
                completionBlock(nil);
            }
        }
    }];
}

- (void) loadSurveyOnCompletion: (void (^)(NSError * error)) completionBlock
{
    if ([APCTask serverDisabled] || self.taskDescription) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                completionBlock(nil);
            }
        });
    }
    else
    {
        [SBBComponent(SBBSurveyManager) getSurveyByRef:self.taskHRef completion:^(id survey, NSError *error) {
            if (!error)
            {
                SBBSurvey * sbbSurvey = (SBBSurvey*) survey;
                [self.managedObjectContext performBlockAndWait:^{
                    self.taskTitle = sbbSurvey.name;
                    self.rkTask = [APCTask rkTaskFromSBBSurvey:survey];
                    NSError * saveError;
                    [self saveToPersistentStore:&saveError];
                    APCLogError2(saveError);
                }];
            }
            else
            {
                APCLogError2 (error);
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!error) {
                    APCLogEventWithData(kNetworkEvent, (@{@"event_detail":[NSString stringWithFormat:@"Loaded Survey %@", self.taskHRef]}));
                }
                if (completionBlock) {
                    completionBlock(error);
                }
            });
        }];
    }
}


/*********************************************************************************/
#pragma mark - SBB to APCSmartSurvey Conversion
/*********************************************************************************/
+ (id<ORKTask>) rkTaskFromSBBSurvey: (SBBSurvey*) survey
{
    APCSmartSurveyTask * retTask = [[APCSmartSurveyTask alloc] initWithIdentifier:survey.identifier survey:survey];
    return retTask;
}



@end


