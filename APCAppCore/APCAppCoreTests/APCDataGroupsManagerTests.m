//
//  APCDataGroupsManagerTests.m
//  APCAppCore
//
// Copyright (c) 2015, Sage Bionetworks. All rights reserved.
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

#import <XCTest/XCTest.h>
#import <APCAppCore/APCAppCore.h>

@interface APCDataGroupsManagerTests : XCTestCase

@end

@interface MockAPCUser : APCUser
@property (nonatomic) NSArray *dataGroupsOverride;
@end

@implementation APCDataGroupsManagerTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testNeedsDataGroup_YES {
    APCDataGroupsManager * manager = [self createDataGroupsManagerWithDataGroups:nil];
    XCTAssertTrue([manager needsUserInfoDataGroups]);
}

- (void)testNeedsDataGroup_NO {
    APCDataGroupsManager * manager = [self createDataGroupsManagerWithDataGroups:@[@"control"]];
    XCTAssertFalse([manager needsUserInfoDataGroups]);
}

- (void)testIsControlGroup_YES {
    APCDataGroupsManager * manager = [self createDataGroupsManagerWithDataGroups:@[@"control"]];
    XCTAssertTrue([manager isStudyControlGroup]);
}

- (void)testIsControlGroup_NO {
    APCDataGroupsManager * manager = [self createDataGroupsManagerWithDataGroups:@[@"studyA"]];
    XCTAssertFalse([manager isStudyControlGroup]);
}

- (void)testSurveyItems_ControlGroup {
    
    APCDataGroupsManager * manager = [self createDataGroupsManagerWithDataGroups:@[@"control", @"studyB"]];
    NSArray <APCTableViewRow *> * rows = [manager surveyItems];
    
    XCTAssertEqual(rows.count, 1);
    
    APCTableViewCustomPickerItem *item = (APCTableViewCustomPickerItem *)[[rows firstObject] item];
    XCTAssertTrue([item isKindOfClass:[APCTableViewCustomPickerItem class]]);
    
    XCTAssertNotNil(item.reuseIdentifier);
    XCTAssertEqualObjects(item.questionIdentifier, @"control_question");
    XCTAssertEqualObjects(item.caption, @"Have you ever been diagnosed with XYZ?");
    
    NSArray *expectedPickerOptions = @[@[@"Yes", @"No"]];
    XCTAssertEqualObjects(item.pickerData, expectedPickerOptions);
    
    NSArray *expectedSelectedIndices = @[@1];
    XCTAssertEqualObjects(item.selectedRowIndices, expectedSelectedIndices);
}

- (void)testSurveyItems_StudyAGroup {
    
    APCDataGroupsManager * manager = [self createDataGroupsManagerWithDataGroups:@[@"studyA", @"studyB"]];
    NSArray <APCTableViewRow *> * rows = [manager surveyItems];
    
    XCTAssertEqual(rows.count, 1);
    
    APCTableViewCustomPickerItem *item = (APCTableViewCustomPickerItem *)[[rows firstObject] item];
    XCTAssertTrue([item isKindOfClass:[APCTableViewCustomPickerItem class]]);
    
    XCTAssertNotNil(item.reuseIdentifier);
    XCTAssertEqualObjects(item.questionIdentifier, @"control_question");
    XCTAssertEqualObjects(item.caption, @"Have you ever been diagnosed with XYZ?");
    
    NSArray *expectedPickerOptions = @[@[@"Yes", @"No"]];
    XCTAssertEqualObjects(item.pickerData, expectedPickerOptions);
    
    NSArray *expectedSelectedIndices = @[@0];
    XCTAssertEqualObjects(item.selectedRowIndices, expectedSelectedIndices);
}

- (void)testSurveyItems_NoProfile {
    
    APCDataGroupsManager * manager = [self createDataGroupsManagerWithDataGroups:@[@"studyA", @"studyB"] required:NO questionOptional:NO includeProfile:NO];
    NSArray <APCTableViewRow *> * rows = [manager surveyItems];
    
    // If the data groups should *not* show up in the profile (by default) then should return nil
    XCTAssertNil(rows);
}

- (void)testSetSurveyAnswer_ChangeToControl
{
    APCDataGroupsManager * manager = [self createDataGroupsManagerWithDataGroups:@[@"studyA", @"studyB"]];
    APCTableViewCustomPickerItem *item = (APCTableViewCustomPickerItem *)[[[manager surveyItems] firstObject] item];
    XCTAssertNotNil(item);
    
    // Change the survey answer
    item.selectedRowIndices = @[@1];
    [manager setSurveyAnswerWithItem:item];
    
    // Check results using set b/c order of the groups does not matter
    NSSet *expectedGroups = [NSSet setWithArray:@[@"control", @"studyB"]];
    NSSet *actualGroups = [NSSet setWithArray:manager.dataGroups];
    XCTAssertEqualObjects(actualGroups, expectedGroups);
    XCTAssertTrue(manager.hasChanges);
}

- (void)testSetSurveyAnswer_ChangeToStudyA
{
    APCDataGroupsManager * manager = [self createDataGroupsManagerWithDataGroups:@[@"control", @"studyB"]];
    APCTableViewCustomPickerItem *item = (APCTableViewCustomPickerItem *)[[[manager surveyItems] firstObject] item];
    XCTAssertNotNil(item);
    
    // Change the survey answer
    item.selectedRowIndices = @[@0];
    [manager setSurveyAnswerWithItem:item];
    
    // Check the results using a set b/c the order of the groups does not matter
    NSSet *expectedGroups = [NSSet setWithArray:@[@"studyA", @"studyB"]];
    NSSet *actualGroups = [NSSet setWithArray:manager.dataGroups];
    XCTAssertEqualObjects(actualGroups, expectedGroups);
    XCTAssertTrue(manager.hasChanges);
}

- (void)testSetSurveyAnswer_NoChange
{
    APCDataGroupsManager * manager = [self createDataGroupsManagerWithDataGroups:@[@"control", @"studyB"]];
    APCTableViewCustomPickerItem *item = (APCTableViewCustomPickerItem *)[[[manager surveyItems] firstObject] item];
    XCTAssertNotNil(item);
    
    // Change the survey answer
    [manager setSurveyAnswerWithItem:item];
    
    // Check the results using a set b/c the order of the groups does not matter
    NSSet *expectedGroups = [NSSet setWithArray:@[@"control", @"studyB"]];
    NSSet *actualGroups = [NSSet setWithArray:manager.dataGroups];
    XCTAssertEqualObjects(actualGroups, expectedGroups);
    XCTAssertFalse(manager.hasChanges);
}

- (void)testSurveySteps_NotOptional
{
    APCDataGroupsManager * manager = [self createDataGroupsManagerWithDataGroups:nil];
    
    ORKFormStep * step = [manager surveyStep];

    XCTAssertNotNil(step);
    XCTAssertFalse(step.optional);
    XCTAssertEqualObjects(step.title, @"Are you in Control?");
    XCTAssertEqualObjects(step.text, @"Engineers and scientists like classifications. To help us better classify you, please answer this question.");
    
    XCTAssertEqual(step.formItems.count, 1);
    ORKFormItem  *item = step.formItems.firstObject;
    XCTAssertEqualObjects(item.identifier, @"control_question");
    XCTAssertEqualObjects(item.text, @"Have you ever been diagnosed with XYZ?");
    
    ORKTextChoiceAnswerFormat *answerFormat = (ORKTextChoiceAnswerFormat *)item.answerFormat;
    XCTAssertTrue([answerFormat isKindOfClass:[ORKTextChoiceAnswerFormat class]]);
    XCTAssertEqual(answerFormat.style, ORKChoiceAnswerStyleSingleChoice);
    
    XCTAssertEqual(answerFormat.textChoices.count, 2);
    NSArray *expectedChoices = @[[ORKTextChoice choiceWithText:@"Yes" value:@YES],
                                 [ORKTextChoice choiceWithText:@"No" value:@NO]];
    XCTAssertEqualObjects(answerFormat.textChoices, expectedChoices);
}

- (void)testSurveySteps_Optional
{
    APCDataGroupsManager * manager = [self createDataGroupsManagerWithDataGroups:nil required:NO questionOptional:YES includeProfile:NO];
    
    ORKFormStep * step = [manager surveyStep];
    
    XCTAssertNotNil(step);
    XCTAssertFalse(step.optional);
    XCTAssertEqualObjects(step.title, @"Are you in Control?");
    XCTAssertEqualObjects(step.text, @"Engineers and scientists like classifications. To help us better classify you, please answer this question.");
    
    XCTAssertEqual(step.formItems.count, 1);
    ORKFormItem  *item = step.formItems.firstObject;
    XCTAssertEqualObjects(item.identifier, @"control_question");
    XCTAssertEqualObjects(item.text, @"Have you ever been diagnosed with XYZ?");
    
    ORKTextChoiceAnswerFormat *answerFormat = (ORKTextChoiceAnswerFormat *)item.answerFormat;
    XCTAssertTrue([answerFormat isKindOfClass:[ORKTextChoiceAnswerFormat class]]);
    XCTAssertEqual(answerFormat.style, ORKChoiceAnswerStyleSingleChoice);
    
    NSArray *expectedChoices = @[[ORKTextChoice choiceWithText:@"Yes" value:@YES],
                                 [ORKTextChoice choiceWithText:@"No" value:@NO],
                                 [ORKTextChoice choiceWithText:@"Prefer not to answer" value:@(NSNotFound)]];
    XCTAssertEqual(answerFormat.textChoices.count, expectedChoices.count);
    XCTAssertEqualObjects(answerFormat.textChoices, expectedChoices);
}

- (void)testSetSurveyAnswerWithStepResult_StudyA
{
    APCDataGroupsManager * manager = [self createDataGroupsManagerWithDataGroups:nil];
    
    // Change the survey answer
    ORKChoiceQuestionResult *result = [[ORKChoiceQuestionResult alloc] initWithIdentifier:@"control_question"];
    result.choiceAnswers = @[@YES];
    ORKStepResult *stepResult = [[ORKStepResult alloc] initWithStepIdentifier:APCDataGroupsStepIdentifier results:@[result]];
    
    [manager setSurveyAnswerWithStepResult:stepResult];
    
    // Check the results using a set b/c the order of the groups does not matter
    XCTAssertEqual(manager.dataGroups.count, 1);
    NSString *actualGroup = [manager.dataGroups firstObject];
    XCTAssertTrue([actualGroup isKindOfClass:[NSString class]], @"%@", NSStringFromClass([actualGroup class]));
    XCTAssertEqualObjects(actualGroup, @"studyA");
}

- (void)testSetSurveyAnswerWithStepResult_Control
{
    APCDataGroupsManager * manager = [self createDataGroupsManagerWithDataGroups:nil];
    
    // Change the survey answer
    ORKChoiceQuestionResult *result = [[ORKChoiceQuestionResult alloc] initWithIdentifier:@"control_question"];
    result.choiceAnswers = @[@NO];
    ORKStepResult *stepResult = [[ORKStepResult alloc] initWithStepIdentifier:APCDataGroupsStepIdentifier results:@[result]];
    
    [manager setSurveyAnswerWithStepResult:stepResult];
    
    // Check the results using a set b/c the order of the groups does not matter
    XCTAssertEqual(manager.dataGroups.count, 1);
    NSString *actualGroup = [manager.dataGroups firstObject];
    XCTAssertTrue([actualGroup isKindOfClass:[NSString class]], @"%@", NSStringFromClass([actualGroup class]));
    XCTAssertEqualObjects(actualGroup, @"control");
}

- (void)testSetSurveyAnswerWithStepResult_Skipped
{
    APCDataGroupsManager * manager = [self createDataGroupsManagerWithDataGroups:nil required:NO questionOptional:YES includeProfile:NO];
    
    // Change the survey answer
    ORKChoiceQuestionResult *result = [[ORKChoiceQuestionResult alloc] initWithIdentifier:@"control_question"];
    result.choiceAnswers = @[@(NSNotFound)];
    ORKStepResult *stepResult = [[ORKStepResult alloc] initWithStepIdentifier:APCDataGroupsStepIdentifier results:@[result]];
    
    [manager setSurveyAnswerWithStepResult:stepResult];
    
    // For a skipped question, the data groups are *not* set to anything
    XCTAssertEqual(manager.dataGroups.count, 0);
    XCTAssertFalse(manager.hasChanges);

}

- (void)testStepResult_Control {
    APCDataGroupsManager * manager = [self createDataGroupsManagerWithDataGroups:@[@"control", @"studyB"]];
    
    ORKStepResult *result = [manager stepResult];
    
    XCTAssertNotNil(result);
    XCTAssertEqualObjects(result.identifier, APCDataGroupsStepIdentifier);
    XCTAssertEqual(result.results.count, 1);
    
    ORKChoiceQuestionResult *questionResult = (ORKChoiceQuestionResult*)[result.results firstObject];
    XCTAssertTrue([questionResult isKindOfClass:[ORKChoiceQuestionResult class]]);
    XCTAssertEqualObjects(questionResult.identifier, @"control_question");
    XCTAssertEqualObjects(questionResult.choiceAnswers, @[@NO]);
}

- (void)testStepResult_StudyA {
    APCDataGroupsManager * manager = [self createDataGroupsManagerWithDataGroups:@[@"studyA", @"studyB"]];
    
    ORKStepResult *result = [manager stepResult];
    
    XCTAssertNotNil(result);
    XCTAssertEqualObjects(result.identifier, APCDataGroupsStepIdentifier);
    XCTAssertEqual(result.results.count, 1);
    
    ORKChoiceQuestionResult *questionResult = (ORKChoiceQuestionResult*)[result.results firstObject];
    XCTAssertTrue([questionResult isKindOfClass:[ORKChoiceQuestionResult class]]);
    XCTAssertEqualObjects(questionResult.identifier, @"control_question");
    XCTAssertEqualObjects(questionResult.choiceAnswers, @[@YES]);
}

- (void)testStepResult_None {
    APCDataGroupsManager * manager = [self createDataGroupsManagerWithDataGroups:@[@"studyB"]];
    
    XCTAssertNil([manager stepResult]);
}

#pragma mark - heper methods

- (APCDataGroupsManager*)createDataGroupsManagerWithDataGroups:(NSArray*)dataGroups {
    return [self createDataGroupsManagerWithDataGroups:dataGroups required:YES questionOptional:NO includeProfile:YES];
}

- (APCDataGroupsManager*)createDataGroupsManagerWithDataGroups:(NSArray*)dataGroups
                                                      required:(BOOL)required
                                              questionOptional:(BOOL)questionOptional includeProfile:(BOOL)includeProfile {

    
    NSArray *questions = @[
                           @{
                               @"identifier": @"control_question",
                               @"text": @"Have you ever been diagnosed with XYZ?",
                               @"type": @"boolean",
                               @"optional": @(questionOptional),
                               @"valueMap": @[@{ @"value" : @YES,
                                                 @"groups" : @[@"studyA"]},
                                              @{ @"value" : @NO,
                                                 @"groups" : @[@"control"]}
                                              ]
                               },
                           ];
    NSDictionary *profile = includeProfile ? @{@"questions": questions} : @{};
    
    NSDictionary *mapping = @{
        @"items": @[@{ @"group_name"            : @"control",
                       @"is_control_group"      : @(true),
                       },
                    @{ @"group_name"            : @"studyA",
                       @"is_control_group"      : @(false),
                       },
                    @{ @"group_name"            : @"studyB",
                       @"is_control_group"      : @(false),
                       }
                  ],
        @"required": @(required),
        @"profile": profile,
        @"survey": @{
            @"title": @"Are you in Control?",
            @"text": @"Engineers and scientists like classifications. To help us better classify you, please answer this question.",
            @"questions":questions,
            }};
    
    return [[APCDataGroupsManager alloc] initWithDataGroups:dataGroups mapping:mapping];
}

@end

// Mock is used to override the storage to NSUserDefaults syoung 01/12/2015
@implementation MockAPCUser

- (NSArray *)dataGroups {
    return self.dataGroupsOverride;
}

- (void)setDataGroups:(NSArray *)dataGroups {
    self.dataGroupsOverride = dataGroups;
}

@end
