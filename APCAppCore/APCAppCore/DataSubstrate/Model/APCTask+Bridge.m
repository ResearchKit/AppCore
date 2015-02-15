// 
//  APCTask+Bridge.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "APCTask+Bridge.h"
#import <ResearchKit/ResearchKit.h>
#import <BridgeSDK/BridgeSDK.h>
#import <Foundation/Foundation.h>
#import "APCSmartSurveyTask.h"

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
+ (id<RKSTTask>) rkTaskFromSBBSurvey: (SBBSurvey*) survey
{
    APCSmartSurveyTask * retTask = [[APCSmartSurveyTask alloc] initWithIdentifier:survey.identifier survey:survey];
    return retTask;
}



@end


