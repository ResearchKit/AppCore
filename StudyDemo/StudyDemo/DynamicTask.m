//
//  DynamicTask.m
//  StudyDemo
//
//  Copyright (c) 2014 Apple. All rights reserved.
//

#import "DynamicTask.h"

@interface DynamicTask ()

@property (nonatomic, strong) RKIntroductionStep* step1;
@property (nonatomic, strong) RKQuestionStep* step2;
@property (nonatomic, strong) RKQuestionStep* step3a;
@property (nonatomic, strong) RKQuestionStep* step3b;
@property (nonatomic, strong) RKActiveStep* step4;

@end

@implementation DynamicTask


- (instancetype)init
{
    self = [super init];
    if (self) {
        [self step1];
        [self step2];
        [self step3a];
        [self step3b];
        [self step4];
    }
    return self;
}

- (NSString *)identifier{
    return @"DynamicTask01";
}

- (NSString *)name{
    return @"DynamicTask";
}

- (RKStep *)stepAfterStep:(RKStep *)step withSurveyResults:(NSDictionary *)surveyResults{
    
    if (step == nil) {
        return _step1;
    }else if (step == _step1){
        return _step2;
    }else if (step == _step2){
        RKQuestionResult* result = surveyResults[step.identifier];
        if (result == nil || result.answer == nil) {
            return nil;
        }else{
            NSInteger index = [(NSNumber*)result.answer integerValue];
            if (index == 0) {
                return _step3a;
            }else if(index == 1){
                return _step3b;
            }
        }
    }else if (step == _step3a || step == _step3b){
        RKQuestionResult* result = surveyResults[step.identifier];
        if (result == nil || result.answer == nil) {
            return nil;
        }else{
            if ([(NSNumber*)result.answer boolValue]) {
                return _step4;
            }
        }
    }

    return nil;
}


- (RKStep *)stepBeforeStep:(RKStep *)step withSurveyResults:(NSDictionary *)surveyResults{
    
    if (step == nil || step == _step1) {
        return nil;
    }else if (step == _step2){
        return _step1;
    }else if (step == _step3a || step == _step3b){
        return _step2;
    }else if (step == _step4 ){
        
        if (surveyResults[_step3a.identifier]) {
             return _step3a;
        }else{
            return _step3b;
        }
    }
    
    return nil;
}

- (RKIntroductionStep *)step1{
    if (_step1 == nil) {
        _step1 = [[RKIntroductionStep alloc] initWithIdentifier:@"step1" name:@"name"];
        _step1.caption = @"This is a dynamic task";
    }
    return _step1;
}


- (RKQuestionStep *)step2{
    if (_step2 == nil) {
        _step2 = [[RKQuestionStep alloc] initWithIdentifier:@"step2" name:@"name"];
        _step2.question = @"Which route do you prefer?";
        _step2.prompt = @"Please choose from the options below:";
        _step2.answerFormat = [RKChoiceAnswerFormat choiceAnswerWithOptions:@[@"route1", @"route2"] style:RKChoiceAnswerStyleSingleChoice];
        _step2.optional = NO;
    }
    
    return _step2;
}

- (RKQuestionStep *)step3a{
    if (_step3a == nil) {
        _step3a = [[RKQuestionStep alloc] initWithIdentifier:@"step3a" name:@"name"];
        _step3a.question = @"You chose route1. Do you like it?";
        _step3a.answerFormat = [RKBooleanAnswerFormat new];
        _step3a.optional = NO;
    }
    
    return _step3a;
}

- (RKQuestionStep *)step3b{
    if (_step3b == nil) {
        _step3b = [[RKQuestionStep alloc] initWithIdentifier:@"step3b" name:@"name"];
        _step3b.question = @"You chose route2. Do you like it?";
        _step3b.answerFormat = [RKBooleanAnswerFormat new];
        _step3b.optional = NO;
    }
    
    return _step3b;
}


- (RKActiveStep *)step4{
    if (_step4 == nil) {
        _step4 = [[RKActiveStep alloc] initWithIdentifier:@"step4" name:@"name"];
        _step4.caption = @"Thank you for enjoying the route.";
        _step4.voicePrompt = @"Thank you for enjoying the route.";
        
    }
    
    return _step4;
}


@end
