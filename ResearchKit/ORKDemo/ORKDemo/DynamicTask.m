//
//  DynamicTask.m
//  StudyDemo
//
//  Copyright (c) 2014 Apple. All rights reserved.
//

#import "DynamicTask.h"
#import <ResearchKit/ResearchKit_Private.h>

@interface DynamicTask ()

@property (nonatomic, strong) ORKInstructionStep* step1;
@property (nonatomic, strong) ORKQuestionStep* step2;
@property (nonatomic, strong) ORKQuestionStep* step3a;
@property (nonatomic, strong) ORKQuestionStep* step3b;
@property (nonatomic, strong) ORKActiveStep* step4;

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

- (ORKStep *)stepAfterStep:(ORKStep *)step withResult:(id<ORKTaskResultSource>)result {
    
    NSString *ident = step.identifier;
    if (step == nil) {
        return self.step1;
    }else if ([ident isEqualToString:self.step1.identifier]){
        return self.step2;
    }else if ([ident isEqualToString:self.step2.identifier]){
        ORKStepResult *stepResult = [result stepResultForStepIdentifier:step.identifier];
        ORKQuestionResult* result = stepResult.results.count > 0 ? [stepResult.results firstObject] : nil;
        if (result == nil || result.answer == nil || result.answer == [NSNull null]) {
            return nil;
        } else {
            if ([[(NSArray *)result.answer firstObject] isEqualToString:@"route1"])
            {
                return self.step3a;
            }
            else
            {
                return self.step3b;
            }
        }
    }else if ([ident isEqualToString:self.step3a.identifier] || [ident isEqualToString:self.step3b.identifier]){
        ORKStepResult *stepResult = [result stepResultForStepIdentifier:step.identifier];
        ORKQuestionResult* result = (ORKQuestionResult*)[stepResult firstResult];
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


- (ORKStep *)stepBeforeStep:(ORKStep *)step withResult:(ORKTaskResult *)result {
    NSString *ident = step.identifier;
    if (ident == nil || [ident isEqualToString:self.step1.identifier]) {
        return nil;
    } else if ([ident isEqualToString:self.step2.identifier]) {
        return self.step1;
    } else if ([ident isEqualToString:self.step3a.identifier] || [ident isEqualToString:self.step3b.identifier]) {
        return self.step2;
    } else if ([ident isEqualToString:self.step4.identifier] ) {
        ORKQuestionResult *questionResult = (ORKQuestionResult *)[(ORKStepResult *)[result stepResultForStepIdentifier:self.step3a.identifier] firstResult];
        
        if (questionResult) {
             return self.step3a;
        } else {
            return self.step3b;
        }
    }
    
    return nil;
}


// Explicitly hide progress indication for some steps
- (ORKTaskProgress)progressOfCurrentStep:(ORKStep *)step withResultProvider:(NSArray *)surveyResults {
    return (ORKTaskProgress){.total = 0, .current = 0};
}

- (ORKInstructionStep *)step1{
    if (_step1 == nil) {
        _step1 = [[ORKInstructionStep alloc] initWithIdentifier:@"step1"];
        _step1.title = @"This is a dynamic task";
    }
    return _step1;
}


- (ORKQuestionStep *)step2{
    if (_step2 == nil) {
        _step2 = [[ORKQuestionStep alloc] initWithIdentifier:@"step2"];
        _step2.title = @"Which route do you prefer?";
        _step2.text = @"Please choose from the options below:";
        _step2.answerFormat = [ORKAnswerFormat choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleSingleChoice textChoices:@[@"route1", @"route2"]];
        _step2.optional = NO;
    }
    
    return _step2;
}

- (ORKQuestionStep *)step3a{
    if (_step3a == nil) {
        _step3a = [[ORKQuestionStep alloc] initWithIdentifier:@"step3a"];
        _step3a.title = @"You chose route1. Do you like it?";
        _step3a.answerFormat = [ORKBooleanAnswerFormat new];
        _step3a.optional = NO;
    }
    
    return _step3a;
}

- (ORKQuestionStep *)step3b{
    if (_step3b == nil) {
        _step3b = [[ORKQuestionStep alloc] initWithIdentifier:@"step3b"];
        _step3b.title = @"You chose route2. Do you like it?";
        _step3b.answerFormat = [ORKBooleanAnswerFormat new];
        _step3b.optional = NO;
    }
    
    return _step3b;
}


- (ORKActiveStep *)step4{
    if (_step4 == nil) {
        _step4 = [[ORKActiveStep alloc] initWithIdentifier:@"step4"];
        _step4.title = @"Thank you for enjoying the route.";
        _step4.spokenInstruction = @"Thank you for enjoying the route.";
        
    }
    
    return _step4;
}


@end
