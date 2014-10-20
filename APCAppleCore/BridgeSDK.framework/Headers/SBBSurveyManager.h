//
//  SBBSurveyManager.h
//  BridgeSDK
//
//  Created by Erin Mounts on 10/9/14.
//  Copyright (c) 2014 Sage Bionetworks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBBBridgeAPIManager.h"


/*!
 Completion block called when retrieving a survey from the API.
 
 @param survey By default, an SBBSurvey object, unless the Survey type has been mapped in SBBObjectManager setupMappingForType:toClass:fieldToPropertyMappings:
 @param error       An error that occurred during execution of the method for which this is a completion block, or nil.
 */
typedef void (^SBBSurveyManagerGetCompletionBlock)(id survey, NSError *error);

/*!
 Completion block called when submitting answers to a survey to the API.
 
 @param guidHolder By default, an SBBGuidHolder object, unless the GuidHolder type has been mapped in SBBObjectManager setupMappingForType:toClass:fieldToPropertyMappings:. The guid in question is the guid of the SurveyResponse object created by submitting this set of answers, which can be used to later amend or delete the answers to this instance of taking the survey.
 @param error          An error that occurred during execution of the method for which this is a completion block, or nil.
 */
typedef void (^SBBSurveyManagerSubmitAnswersCompletionBlock)(id guidHolder, NSError *error);

/*!
 Completion block called when retrieving a survey response from the API.
 
 @param surveyResponse By default, an SBBSurveyResponse object, unless the SurveyResponse type has been mapped in SBBObjectManager setupMappingForType:toClass:fieldToPropertyMappings:
 @param error       An error that occurred during execution of the method for which this is a completion block, or nil.
 */
typedef void (^SBBSurveyManagerGetResponseCompletionBlock)(id surveyResponse, NSError *error);

/*!
 Completion block called when updating or deleting a survey response to the API.
 
 @param responseObject JSON response from the server.
 @param error          An error that occurred during execution of the method for which this is a completion block, or nil.
 */
typedef void (^SBBSurveyManagerEditResponseCompletionBlock)(id responseObject, NSError *error);

/*!
 *  This protocol defines the interface to the SBBSurveyManager's non-constructor, non-initializer methods. The interface is
 *  abstracted out for use in mock objects for testing, and to allow selecting among multiple implementations at runtime.
 */
@protocol SBBSurveyManagerProtocol <SBBBridgeAPIManagerProtocol>

/*!
 Fetch a survey from the Bridge API via an activityRef (href).
 
 @param ref        The href identifying the desired survey, obtained e.g. from the Schedules or Activities API.
 @param completion An SBBSurveyManagerGetCompletionBlock to be called upon completion.
 
 @return An NSURLSessionDataTask object so you can cancel or suspend/resume the request.
 */
- (NSURLSessionDataTask *)getSurveyByRef:(NSString *)ref completion:(SBBSurveyManagerGetCompletionBlock)completion;

/*!
 Fetch a survey from the Bridge API by guid and version number.
 
 @param guid       The survey's guid.
 @param versionedOn    The date-time-versioned-on of the survey to fetch.
 @param completion An SBBSurveyManagerGetCompletionBlock to be called upon completion.
 
 @return An NSURLSessionDataTask object so you can cancel or suspend/resume the request.
 */
- (NSURLSessionDataTask *)getSurveyByGuid:(NSString *)guid versionedOn:(NSDate *)versionedOn completion:(SBBSurveyManagerGetCompletionBlock)completion;

/*!
 Submit a set of answers to a survey by the survey's activityRef (href).
 
 @param surveyAnswers An NSArray of survey answer objects for the questions answered.
 @param ref           The href identifying the survey being answered, obtained e.g. from the Schedules or Activities API.
 @param completion An SBBSurveyManagerSubmitAnswersCompletionBlock to be called upon completion. The guidHolder passed in contains the guid of the survey response created by submitting these answers.
 
 @return An NSURLSessionDataTask object so you can cancel or suspend/resume the request.
 */
- (NSURLSessionDataTask *)submitAnswers:(NSArray *)surveyAnswers toSurveyByRef:(NSString *)ref completion:(SBBSurveyManagerSubmitAnswersCompletionBlock)completion;

/*!
 Submit a set of answers to a survey by the survey's guid and version number.
 
 @param surveyAnswers An NSArray of survey answer objects for the questions answered.
 @param guid       The survey's guid.
 @param versionedOn    The date-time-versioned-on of the survey being answered.
 @param completion An SBBSurveyManagerSubmitAnswersCompletionBlock to be called upon completion. The guidHolder passed in contains the guid of the survey response created by submitting these answers.
 
 @return An NSURLSessionDataTask object so you can cancel or suspend/resume the request.
 */
- (NSURLSessionDataTask *)submitAnswers:(NSArray *)surveyAnswers toSurveyByGuid:(NSString *)guid versionedOn:(NSDate *)versionedOn completion:(SBBSurveyManagerSubmitAnswersCompletionBlock)completion;

/*!
 Fetch a previously-started survey response from the Bridge API.
 
 @param guid       The guid of the desired survey response.
 @param completion An SBBSurveyManagerGetResponseCompletionBlock to be called upon completion.
 
 @return An NSURLSessionDataTask object so you can cancel or suspend/resume the request.
 */
- (NSURLSessionDataTask *)getSurveyResponse:(NSString *)guid completion:(SBBSurveyManagerGetResponseCompletionBlock)completion;

/*!
 Add answers to an existing survey response.
 
 @param surveyAnswers An NSArray of survey answer objects for the questions answered.
 @param guid          The survey response's guid.
 @param completion    An SBBSurveyManagerEditResponseCompletionBlock to be called upon completion.
 
 @return An NSURLSessionDataTask object so you can cancel or suspend/resume the request.
 */
- (NSURLSessionDataTask *)addAnswers:(NSArray *)surveyAnswers toSurveyResponse:(NSString *)guid completion:(SBBSurveyManagerEditResponseCompletionBlock)completion;

/*!
 Delete an existing survey response.
 
 @param guid          The survey response's guid.
 @param completion    An SBBSurveyManagerEditResponseCompletionBlock to be called upon completion.
 
 @return An NSURLSessionDataTask object so you can cancel or suspend/resume the request.
 */
- (NSURLSessionDataTask *)deleteSurveyResponse:(NSString *)guid completion:(SBBSurveyManagerEditResponseCompletionBlock)completion;

@end

/*!
 *  This class handles communication with the Bridge surveys API.
 */
@interface SBBSurveyManager : SBBBridgeAPIManager<SBBComponent, SBBSurveyManagerProtocol>

@end
