//
//  ORKOrderedTask+APCHelperTests.m
//  APCAppCore
//
// Copyright (c) 2015 Apple, Inc. All rights reserved.
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
#import <APCAppCore/ORKOrderedTask+APCHelper.h>

@interface ORKOrderedTask_APCHelperTests : XCTestCase

@end

@implementation ORKOrderedTask_APCHelperTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testTwoFingerTappingIntervalTaskWithIdentifier_TapHandOptionUndefined {
    
    ORKOrderedTask *task = [ORKOrderedTask twoFingerTappingIntervalTaskWithIdentifier:@"test"
                                                               intendedUseDescription:nil
                                                                             duration:10
                                                                              options:0
                                                                          handOptions:0];

    for (ORKStep *step in task.steps) {
        XCTAssertFalse([step.identifier.lowercaseString containsString:@"left"]);
        XCTAssertFalse([step.identifier.lowercaseString containsString:@"right"]);
        XCTAssertFalse([step.title.lowercaseString containsString:@"right"]);
        XCTAssertFalse([step.title.lowercaseString containsString:@"left"]);
        XCTAssertFalse([step.text.lowercaseString containsString:@"right"]);
        XCTAssertFalse([step.text.lowercaseString containsString:@"left"]);
    }
}

- (void)testTwoFingerTappingIntervalTaskWithIdentifier_TapHandOptionLeft {
    
    ORKOrderedTask *task = [ORKOrderedTask twoFingerTappingIntervalTaskWithIdentifier:@"test"
                                                               intendedUseDescription:nil
                                                                             duration:10
                                                                              options:0
                                                                          handOptions:APCTapHandOptionLeft];
    // Check assumption around how many steps
    XCTAssertEqual(task.steps.count, 4);
    
    // Check that none of the language or identifiers contain the word "right"
    for (ORKStep *step in task.steps) {
        XCTAssertFalse([step.identifier.lowercaseString hasSuffix:APCRightHandIdentifier]);
        XCTAssertFalse([step.title.lowercaseString containsString:@"right"]);
        XCTAssertFalse([step.text.lowercaseString containsString:@"right"]);
    }
    
    NSArray * (^filteredSteps)(NSString*, NSString*) = ^(NSString *part1, NSString *part2) {
        NSString *keyValue = [NSString stringWithFormat:@"%@.%@", part1, part2];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", NSStringFromSelector(@selector(identifier)), keyValue];
        return [task.steps filteredArrayUsingPredicate:predicate];
    };
    
    // Look for instruction step
    NSArray *instructions = filteredSteps(APCTapInstructionStepIdentifier, APCLeftHandIdentifier);
    XCTAssertEqual(instructions.count, 1);
    ORKStep *instructionStep = [instructions firstObject];
    XCTAssertEqualObjects(instructionStep.title, @"Left Hand");
    XCTAssertEqualObjects(instructionStep.text, @"Rest your phone on a flat surface. Then use two fingers on your left hand to alternately tap the buttons that appear. Keep tapping for 10 seconds and time your taps to be as consistent as possible.");
    
    // Look for the activity step
    NSArray *tappings = filteredSteps(APCTapTappingStepIdentifier, APCLeftHandIdentifier);
    XCTAssertEqual(tappings.count, 1);
    ORKStep *tappingStep = [tappings firstObject];
    XCTAssertEqualObjects(tappingStep.title, @"Tap the buttons using your LEFT hand.");
    
}

- (void)testTwoFingerTappingIntervalTaskWithIdentifier_TapHandOptionRight {
    
    ORKOrderedTask *task = [ORKOrderedTask twoFingerTappingIntervalTaskWithIdentifier:@"test"
                                                               intendedUseDescription:nil
                                                                             duration:10
                                                                              options:0
                                                                          handOptions:APCTapHandOptionRight];
    // Check assumption around how many steps
    XCTAssertEqual(task.steps.count, 4);
    
    // Check that none of the language or identifiers contain the word "right"
    for (ORKStep *step in task.steps) {
        XCTAssertFalse([step.identifier.lowercaseString hasSuffix:APCLeftHandIdentifier]);
        XCTAssertFalse([step.title.lowercaseString containsString:@"left"]);
        XCTAssertFalse([step.text.lowercaseString containsString:@"left"]);
    }
    
    NSArray * (^filteredSteps)(NSString*, NSString*) = ^(NSString *part1, NSString *part2) {
        NSString *keyValue = [NSString stringWithFormat:@"%@.%@", part1, part2];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", NSStringFromSelector(@selector(identifier)), keyValue];
        return [task.steps filteredArrayUsingPredicate:predicate];
    };
    
    // Look for instruction step
    NSArray *instructions = filteredSteps(APCTapInstructionStepIdentifier, APCRightHandIdentifier);
    XCTAssertEqual(instructions.count, 1);
    ORKStep *instructionStep = [instructions firstObject];
    XCTAssertEqualObjects(instructionStep.title, @"Right Hand");
    XCTAssertEqualObjects(instructionStep.text, @"Rest your phone on a flat surface. Then use two fingers on your right hand to alternately tap the buttons that appear. Keep tapping for 10 seconds and time your taps to be as consistent as possible.");
    
    // Look for the activity step
    NSArray *tappings = filteredSteps(APCTapTappingStepIdentifier, APCRightHandIdentifier);
    XCTAssertEqual(tappings.count, 1);
    ORKStep *tappingStep = [tappings firstObject];
    XCTAssertEqualObjects(tappingStep.title, @"Tap the buttons using your RIGHT hand.");
    
}

- (void)testTwoFingerTappingIntervalTaskWithIdentifier_TapHandOptionBoth {
    
    ORKOrderedTask *task = [ORKOrderedTask twoFingerTappingIntervalTaskWithIdentifier:@"test"
                                                               intendedUseDescription:nil
                                                                             duration:10
                                                                              options:0
                                                                          handOptions:APCTapHandOptionBoth];
    // Check assumption around how many steps
    XCTAssertEqual(task.steps.count, 6);
    
    ORKStep * (^filteredSteps)(NSString*, NSString*) = ^(NSString *part1, NSString *part2) {
        NSString *keyValue = [NSString stringWithFormat:@"%@.%@", part1, part2];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", NSStringFromSelector(@selector(identifier)), keyValue];
        return [[task.steps filteredArrayUsingPredicate:predicate] firstObject];
    };
    
    // Look for instruction steps
    ORKStep *rightInstructionStep = filteredSteps(APCTapInstructionStepIdentifier, APCRightHandIdentifier);
    XCTAssertNotNil(rightInstructionStep);
    XCTAssertEqualObjects(rightInstructionStep.title, @"Right Hand");
    
    ORKStep *leftInstructionStep = filteredSteps(APCTapInstructionStepIdentifier, APCLeftHandIdentifier);
    XCTAssertNotNil(leftInstructionStep);
    XCTAssertEqualObjects(leftInstructionStep.title, @"Left Hand");
    
    // Depending upon the seed (clock time) this will be either the right or left hand
    // Without using OCMock, cannot easily verify that both will display.
    BOOL isRightFirst = [task.steps indexOfObject:rightInstructionStep] < [task.steps indexOfObject:leftInstructionStep];
    if (isRightFirst) {
        XCTAssertEqualObjects(rightInstructionStep.text, @"Rest your phone on a flat surface. Then use two fingers on your right hand to alternately tap the buttons that appear. Keep tapping for 10 seconds and time your taps to be as consistent as possible.");
        XCTAssertEqualObjects(leftInstructionStep.text, @"Rest your phone on a flat surface. Now repeat the same test using your left hand. Keep tapping for 10 seconds and time your taps to be as consistent as possible.");
    }
    else {
        XCTAssertEqualObjects(leftInstructionStep.text, @"Rest your phone on a flat surface. Then use two fingers on your left hand to alternately tap the buttons that appear. Keep tapping for 10 seconds and time your taps to be as consistent as possible.");
        XCTAssertEqualObjects(rightInstructionStep.text, @"Rest your phone on a flat surface. Now repeat the same test using your right hand. Keep tapping for 10 seconds and time your taps to be as consistent as possible.");
    }
    
    // Look for tapping steps
    ORKStep *rightTapStep = filteredSteps(APCTapTappingStepIdentifier, APCRightHandIdentifier);
    XCTAssertNotNil(rightTapStep);
    XCTAssertEqualObjects(rightTapStep.title, @"Tap the buttons using your RIGHT hand.");
    
    ORKStep *leftTapStep = filteredSteps(APCTapTappingStepIdentifier, APCLeftHandIdentifier);
    XCTAssertNotNil(leftTapStep);
    XCTAssertEqualObjects(leftTapStep.title, @"Tap the buttons using your LEFT hand.");

}

@end
