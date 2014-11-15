//
//  DynamicTask.m
//  StudyDemo
//
//  Copyright (c) 2014 Apple. All rights reserved.
//

#import "DynamicTask.h"
#import <ResearchKit/ResearchKit_Private.h>

@interface DynamicTask ()

@property (nonatomic, strong) RKSTInstructionStep* step1;
@property (nonatomic, strong) RKSTQuestionStep* step2;
@property (nonatomic, strong) RKSTQuestionStep* step3a;
@property (nonatomic, strong) RKSTQuestionStep* step3b;
@property (nonatomic, strong) RKSTActiveStep* step4;

@end

@implementation DynamicTask


- (instancetype)init
{
    self = [super init];
    if (self) {

    }
    return self;
}

- (NSString *)identifier{
    return @"DynamicTask01";
}

- (NSString *)name{
    return @"DynamicTask";
}

- (RKSTStep *)stepAfterStep:(RKSTStep *)step withResult:(id<RKSTTaskResultSource>)result {
    
    NSString *ident = step.identifier;
    if (step == nil) {
        return self.step1;
    }else if ([ident isEqualToString:self.step1.identifier]){
        return self.step2;
    }else if ([ident isEqualToString:self.step2.identifier]){
        RKSTStepResult *stepResult = [result stepResultForStepIdentifier:step.identifier];
        RKSTQuestionResult* result = stepResult.results.count > 0 ? [stepResult.results firstObject] : nil;
        if (result == nil || result.answer == nil || result.answer == [NSNull null]) {
            return nil;
        } else {
            if ([result.answer isEqualToString:@"route1"])
            {
                return self.step3a;
            }
            else
            {
                return self.step3b;
            }
        }
    }else if ([ident isEqualToString:self.step3a.identifier] || [ident isEqualToString:self.step3b.identifier]){
        RKSTStepResult *stepResult = [result stepResultForStepIdentifier:step.identifier];
        RKSTQuestionResult* result = (RKSTQuestionResult*)[stepResult firstResult];
        if (result == nil || result.answer == nil) {
            return nil;
        } else {
            if ([(NSNumber*)result.answer boolValue]) {
                return self.step4;
            }
        }
    }

    return nil;
}


- (RKSTStep *)stepBeforeStep:(RKSTStep *)step withResult:(RKSTTaskResult *)result {
    NSString *ident = step.identifier;
    if (ident == nil || [ident isEqualToString:self.step1.identifier]) {
        return nil;
    } else if ([ident isEqualToString:self.step2.identifier]) {
        return self.step1;
    } else if ([ident isEqualToString:self.step3a.identifier] || [ident isEqualToString:self.step3b.identifier]) {
        return self.step2;
    } else if ([ident isEqualToString:self.step4.identifier] ) {
        RKSTQuestionResult *questionResult = (RKSTQuestionResult *)[(RKSTStepResult *)[result stepResultForStepIdentifier:self.step3a.identifier] firstResult];
        
        if (questionResult) {
             return self.step3a;
        } else {
            return self.step3b;
        }
    }
    
    return nil;
}


// Explicitly hide progress indication for some steps
- (RKSTTaskProgress)progressOfCurrentStep:(RKSTStep *)step withResultProvider:(NSArray *)surveyResults {
    return (RKSTTaskProgress){.total = 0, .current = 0};
}

- (RKSTInstructionStep *)step1{
    if (_step1 == nil) {
        _step1 = [[RKSTInstructionStep alloc] initWithIdentifier:@"step1"];
        _step1.title = @"This is a dynamic task";
    }
    return _step1;
}


- (RKSTQuestionStep *)step2{
    if (_step2 == nil) {
        _step2 = [[RKSTQuestionStep alloc] initWithIdentifier:@"step2"];
        _step2.title = @"Which route do you prefer?";
        _step2.text = @"Please choose from the options below:";
        _step2.answerFormat = [RKSTChoiceAnswerFormat choiceAnswerWithTextOptions:@[@"route1", @"route2"] style:RKChoiceAnswerStyleSingleChoice];
        _step2.optional = NO;
    }
    
    return _step2;
}

- (RKSTQuestionStep *)step3a{
    if (_step3a == nil) {
        _step3a = [[RKSTQuestionStep alloc] initWithIdentifier:@"step3a"];
        _step3a.title = @"You chose route1. Do you like it?";
        _step3a.answerFormat = [RKSTBooleanAnswerFormat new];
        _step3a.optional = NO;
    }
    
    return _step3a;
}

- (RKSTQuestionStep *)step3b{
    if (_step3b == nil) {
        _step3b = [[RKSTQuestionStep alloc] initWithIdentifier:@"step3b"];
        _step3b.title = @"You chose route2. Do you like it?";
        _step3b.answerFormat = [RKSTBooleanAnswerFormat new];
        _step3b.optional = NO;
    }
    
    return _step3b;
}


- (RKSTActiveStep *)step4{
    if (_step4 == nil) {
        _step4 = [[RKSTActiveStep alloc] initWithIdentifier:@"step4"];
        _step4.title = @"Thank you for enjoying the route.";
        _step4.spokenInstruction = @"Thank you for enjoying the route.";
        
    }
    
    return _step4;
}


@end
