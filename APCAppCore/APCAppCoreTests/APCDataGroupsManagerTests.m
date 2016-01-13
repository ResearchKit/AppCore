//
//  APCDataGroupsManagerTests.m
//  APCAppCore
//
//  Created by Shannon Young on 1/12/16.
//  Copyright © 2016 Apple, Inc. All rights reserved.
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
    
    XCTAssertEqualObjects(item.identifier, @"control");
    XCTAssertEqualObjects(item.caption, @"Have you been diagnosed with XYZ?");
    
    NSArray *expectedPickerOptions = @[@"Yes", @"No"];
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
    
    XCTAssertEqualObjects(item.identifier, @"control");
    XCTAssertEqualObjects(item.caption, @"Have you been diagnosed with XYZ?");
    
    NSArray *expectedPickerOptions = @[@"Yes", @"No"];
    XCTAssertEqualObjects(item.pickerData, expectedPickerOptions);
    
    NSArray *expectedSelectedIndices = @[@0];
    XCTAssertEqualObjects(item.selectedRowIndices, expectedSelectedIndices);
}

- (void)testSetSurveyAnswer_ChangeToControl
{
    APCDataGroupsManager * manager = [self createDataGroupsManagerWithDataGroups:@[@"studyA", @"studyB"]];
    
    // Change the survey answer
    [manager setSurveyAnswerWithIdentifier:@"control" selectedIndices:@[@1]];
    
    // Check results using set b/c order of the groups does not matter
    NSSet *expectedGroups = [NSSet setWithArray:@[@"control", @"studyB"]];
    NSSet *actualGroups = [NSSet setWithArray:manager.dataGroups];
    XCTAssertEqualObjects(actualGroups, expectedGroups);
    XCTAssertTrue(manager.hasChanges);
}

- (void)testSetSurveyAnswer_ChangeToStudyA
{
    APCDataGroupsManager * manager = [self createDataGroupsManagerWithDataGroups:@[@"control", @"studyB"]];
    
    // Change the survey answer
    [manager setSurveyAnswerWithIdentifier:@"control" selectedIndices:@[@0]];
    
    // Check the results using a set b/c the order of the groups does not matter
    NSSet *expectedGroups = [NSSet setWithArray:@[@"studyA", @"studyB"]];
    NSSet *actualGroups = [NSSet setWithArray:manager.dataGroups];
    XCTAssertEqualObjects(actualGroups, expectedGroups);
    XCTAssertTrue(manager.hasChanges);
}

- (void)testSetSurveyAnswer_NoChange
{
    APCDataGroupsManager * manager = [self createDataGroupsManagerWithDataGroups:@[@"control", @"studyB"]];
    
    // Change the survey answer
    [manager setSurveyAnswerWithIdentifier:@"control" selectedIndices:@[@1]];
    
    // Check the results using a set b/c the order of the groups does not matter
    NSSet *expectedGroups = [NSSet setWithArray:@[@"control", @"studyB"]];
    NSSet *actualGroups = [NSSet setWithArray:manager.dataGroups];
    XCTAssertEqualObjects(actualGroups, expectedGroups);
    XCTAssertFalse(manager.hasChanges);
}

- (APCDataGroupsManager*)createDataGroupsManagerWithDataGroups:(NSArray*)dataGroups {
    
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
        @"required": @(true),
        @"questions":
        @[
         @{
             @"identifier": @"control",
             @"prompt": @"Have you been diagnosed with XYZ?",
             @"type": @"boolean",
             @"valueMap": @[@{ @"value" : @YES,
                               @"groups" : @[@"studyA"]},
                            @{ @"value" : @NO,
                               @"groups" : @[@"control"]}
                            ]
             },
         ]
        };
    
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
